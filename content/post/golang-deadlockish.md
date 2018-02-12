---
commentURL: 'https://news.ycombinator.com/item?id=16359977'
date: 2018-02-12T10:00:53.000Z
tags:
  - golang
  - deadlock
title: 'Debugging a potential deadlock in Go with go-deadlock'
---

Recently, I tackled a reoccurring issue whose cause wasn't clear for weeks. My team would "do stuff"[^1], and then the problem would go away only to come back a few days to a week later. However, after some hours of debugging it made complete sense. I had just been looking for the problem in the wrong place. I thought I'd share.

The issue was this. Every week or so, we would get a bug report from a client stating our web application was taking a long time to load, didn't seem to load at all, or that actions were slow. It appeared to only happen for one client at a time and we were all able to see the behavior when it happened. Yet, it would generally clear up after a restart of a backing service or cleaning up some data.

However, this time, our quick fixes were not working. The application was not recovering. What was going on?!

# Waiting your turn

In one of our backing services for the application, each group has its own `Room`, so to speak. We were locking the `members` list before we'd broadcast a message to the room to avoid any data races or possible crashes.  Like so:

```go
func (r *Room) Broadcast(msg string) {
	r.membersMx.RLock()
	defer r.membersMx.RUnlock()
	for _, m := range r.members {
		if err := s.Send(msg); err != nil { // ❶
			log.Printf("Broadcast: %v: %v", r.instance, err)
		}
	}
}
```

Notice that we wait _❶_ until each member receives the message before continuing to the next member. This will become problematic in a moment.

# Another clue

Testers also noticed that they could enter the room on a restart of the service and things appeared to work fine for a little bit. However, as soon as they left and came back, the application stopped working properly.  It turned out they were getting hung up in this function that adds a new member to the room:

```go
func (r *Room) Add(s sockjs.Session) {
	r.membersMx.Lock() // ❶
	r.members = append(r.members, s)
	r.membersMx.Unlock()
}
```

We couldn't obtain a lock _❶_ because our `Broadcast` function was still using it to send out messages.

# Finding the problem

Initial investigations pointed to something in the backing service that was getting hung up, but how did we find out where?

Thankfully, with the help of [go-deadlock](https://github.com/sasha-s/go-deadlock), a tool that tracks live mutex usage, we could see that this was occurring. The tool reports when a goroutine has had access to a mutex for 30 seconds or more[^2]. The API mirrors the standard Go libraries making it an easy drop-in checker. The results pointed to the `Add` function waiting on the `Broadcast` function to release its lock.

All of a sudden the client reports made total sense (especially when we found out they were dealing with network sluggishness).

1. A member suffering from high latency joins the room (`Add`) with other members.
2. As soon as they pulled an update (`Broadcast`), all the members start noticing slow updates.
3. Members reload the application, with hopes that it will fix the problem, and try to rejoin (`Add`).
4. However, they cannot because they are waiting for a (`Broadcast`) to finish because it has been slowed down by the high latency member.

# The solution

Since we needed the lock in `Broadcast` in order for our `members` list to not change on us, the solution was to execute all the sends in parallel after getting what we needed from the lock:

```go
func (r *Room) Broadcast(msg string) {
	r.membersMx.RLock()
	defer r.membersMx.RUnlock()
	for _, m := range r.members {
		go func(s sockjs.Session) {
			if err := s.Send(msg); err != nil {
				log.Printf("Broadcast: %v: %v", r.instance, err)
			}
		}(m)
	}
}
```

This has a few advantages:

1. No member needs to wait on another to get a broadcast message.
2. Members join a room without having to wait.
3. Since goroutines are cheap and the sockets are already established (via WebSocket). Multiple asynchronous calls like this shouldn't be an issue.

# Lessons (re)learned
This particular service that caused the application to fail had been in production for many months without any reported issues of this kind which led to the false assumption that the service was doing great as it handles hundreds of thousands of messages a day. However, it wasn't OK. It had a glaring issue brought to light given the right circumstances.

I now plan to ask my future self when using mutex or similar: Can slow I/O cause undesirable behavior when it involves data guarded by a mutex?

[^1]: Clearly a technical term when you restart servers that appear effected to hopefully get them in a better state 😂.
[^2]: In our case, it wasn't a complete deadlock in that the goroutine would eventually relinquish access.
