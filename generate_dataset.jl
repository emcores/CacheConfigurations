include("Dataset.jl")

import .Dataset

root = mkpath("build")
Dataset.clone_gem5(root)
gem5b = Dataset.build_gem5_x86(root)
Dataset.exec_gem5opt_command(
    gem5b, Dataset.base_cacheconfig, joinpath(root,"gem5out"),
    joinpath(root,"gem5","tests","test-progs","hello","bin","x86","linux","hello"),
    ""
)
