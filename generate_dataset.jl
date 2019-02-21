include("Dataset.jl")

import .Dataset

root = mkpath("build")
Dataset.clone_gem5(root)
Dataset.build_gem5_x86(root)