build: clean
	hugo -d dist

clean:
	rm -rf dist resources

run:
	hugo serve -p 3000 -D
