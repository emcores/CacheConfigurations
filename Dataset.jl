module Dataset

function clone_gem5(build_root)
    cwd = pwd()
    cd(build_root)
    run(`git clone https://github.com/emcores/gem5.git`)
    cd(cwd)
end

function build_gem5_x86(build_root)
    cwd = pwd()
    cd(build_root)

    cd(gem5)
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