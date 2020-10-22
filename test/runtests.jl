using DCD
using Test

@testset "DCD.File" begin
    dcd = load_dcd("data/test.dcd")
    @test_throws String load_dcd("data/test.txt") 
    @test dcd isa DCD.File
    @test natoms(dcd) == 3072
    @test nframes(dcd) == 1000
    @test timestep(dcd) == 200.0
    @test hascell(dcd) == true
    @test DCD.nbytes_header(dcd) == 276
    @test DCD.nbytes_frame(dcd) == 36944
    frame, state = iterate(dcd)
    @test frame isa DCD.Frame
    @test state == 2
    @test length(collect(dcd)) == nframes(dcd)
    @test dcd[begin] isa DCD.Frame
    @test dcd[end] isa DCD.Frame
end

@testset "DCD.Frame" begin
    dcd = load_dcd("data/test.dcd")
    f1 = DCD.Frame(dcd, 1)
    f2 = DCD.Frame(dcd, 2)
    @test cell(f1) == [30.73, 30.73, 30.73, 90.0, 90.0, 90.0]
    @test cell(f2) == [30.73, 30.73, 30.73, 90.0, 90.0, 90.0]
    @test size(positions(f1)) == (3, natoms(dcd))
    @test positions(f1)[1] ≈ 4.3010964
    @test timepassed(f1) == 200.0
end


