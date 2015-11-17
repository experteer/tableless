tableless
=========

Even with ActiveModel you might need this

Development:

```
git clone git@github.com:experteer/tableless.git
cd tableless
docker run -it \
  --name tableless \
  --volume $PWD:/home/default/tableless \
  --workdir /home/default/tableless \
  <ruby-image>
```

Build new package for release with

```
default@1d3e1c0bcda2:~/tableless$ bundle exec rake build
```
