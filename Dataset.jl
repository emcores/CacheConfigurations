module Dataset

struct CacheConfig
    l1d_size::String
    l1i_size::String
    l1d_assoc::Int
    l1i_assoc::Int
    cacheline_size::Int
end

const base_cacheconfig = CacheConfig("8kB","8kB",4,4,32)

struct Gem5Build
    build_root::String
    gem5opt::String
    gem5fast::String
    se_script::String
end

struct MiBenchBuild
    build_root::String
end

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
    gem5b = get_gem5build(build_root)
    if verify_gem5build(gem5b)
        println("gem5 build exists, returning")
    else
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
                "'-Wno-unused-parameter'" =>
                "'-Wno-unused-parameter','-Wno-unused-variable'"))
         end
        # build gem5 using scons
        @time run(`scons build/X86/gem5.opt build/X86/gem5.fast -j$(Sys.CPU_THREADS)`)
        cd(cwd)
    end
    return gem5b
end

@inline function get_gem5build(build_root)
    gem5opt = joinpath(build_root,"gem5","build","X86","gem5.opt")
    gem5fast = joinpath(build_root,"gem5","build","X86","gem5.fast")
    gem5scriptse = joinpath(build_root,"gem5","configs","example","se.py")
    return Gem5Build(build_root, gem5opt, gem5fast, gem5scriptse)
end

@inline function verify_gem5build(gem5b::Gem5Build)
    if ispath(gem5b.gem5opt) && ispath(gem5b.gem5fast) && ispath(gem5b.se_script)
        return true
    else
        return false
    end
end

function clone_mibench(build_root)
    cwd = pwd()
    cd(build_root)
    if isdir("mibench")
        println("mibench directory exists, skipping")
    else
        run(`git clone https://github.com/emcores/MiBench.git`)
    end
    cd(cwd)
end

function build_mibench_x86(build_root)
    cwd = pwd()
    cd(build_root)

    cd("MiBench")
    # build MiBench using defaults
    println(pwd())
    juliaexe = Base.julia_exename()
    buildscript = "build.jl"
    cmd = `$juliaexe $buildscript`
    println(cmd)
    @time run(cmd)
    mibenchb = MiBenchBuild(
        build_root
    )
    cd(cwd)
    return mibenchb
end

function exec_gem5opt_command(gem5b::Gem5Build,
    cacheconfig::CacheConfig, outdir::String, exec::String, options::String, maxinsts=0)

    c = cacheconfig
    command = `$(gem5b.gem5opt) --outdir=$outdir
        $(gem5b.se_script) -c $exec -o "$options"
        --l1d_size $(c.l1d_size) --l1i_size $(c.l1i_size)
        --l1d_assoc $(c.l1d_assoc) --l1i_assoc $(c.l1i_assoc)
        --cacheline_size $(c.cacheline_size)
        --caches --cpu-type TimingSimpleCPU`
    if maxinsts > 0
        command = `$command --maxinsts 100000`
    end
    run(command)
end

end
