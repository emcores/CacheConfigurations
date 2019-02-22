module Dataset

function clone_gem5(build_root)
    cwd = pwd()
    cd(build_root)
    if isdir("gem5")
        println("gem5 directory exists, skipping")
    else
        run(`git clone https://github.com/emcores/gem5.git`)
    end
    cd(cwd)
end

function build_gem5_x86(build_root)
    cwd = pwd()
    cd(build_root)

    cd("gem5")
    run(`git checkout bcf6983bc605b884fba52ec74634bddfd395cd5e`)
    # patch gem5 SConstruct to allow building gem5.fast
    filename = "SConstruct"
    run(`git checkout $filename`)
    all_text = read(filename,String)
    open(filename, "w") do f
        write(f, replace(all_text,
            "'-Wno-unused-parameter'",
            "'-Wno-unused-parameter','-Wno-unused-variable'"))
     end
    # build gem5 using scons
    run(`scons build/X86/gem5.opt build/X86/gem5.fast -j$(Sys.CPU_THREADS)`)
    cd(cwd)
end

end