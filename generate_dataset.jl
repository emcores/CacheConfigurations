include("Dataset.jl")
import .Dataset

root = "build"
gem5b = Dataset.get_gem5build(root)

dataset_path = joinpath(root,"dataset")
mkpath(dataset_path)

Dataset.exec_gem5opt_command(
gem5b, Dataset.base_cacheconfig, joinpath(dataset_path,"gem5out"),
joinpath(root,"MiBench","build","gcc","automotive","bitcount","bitcnts"),
"75000", Int64(1e7)
)
