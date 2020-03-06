# CacheConfigurations

## Docker

```
docker build --tag=ubuntu_gem5_julia dockerbuild/
```

```
docker run -v $(pwd):/data -it ubuntu_gem5_julia bash
```

This mounts the current working directory under /data. Then,

```
julia generate_dataset.jl
```
