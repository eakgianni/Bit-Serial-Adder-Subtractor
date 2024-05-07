
/*************************************************
 *
 * EEEE-120, Digital Systems I
 *
 * Bit Serial Adder Subtractor Testbench
 *
 * Mark A. Indovina
 * Rochester Institute of Technology
 *
 * **********************************************/

`timescale 1ns / 1ns

module test;

reg  Clock, Reset;

reg  N, nADD, nADDhold;
reg  [4:0] Xin, Yin;
reg  [3:0] flag, delay;

wire Sh, done, SUB, EQUAL;
wire [4:0] Xout, Yout;
wire [4:0] Sum ;

BSAS5B_top top(
        .Reset(Reset),
        .Clock(Clock),
        .N(N),
        .nADD(nADD),
        .Sh(Sh),
        .SUB(SUB),
        .done(done),
        .Xin(Xin),
        .Xout(Xout),
        .Yin(Yin),
        .Yout(Yout)
    );

assign Sum = nADDhold ? Xin - Yin : Xin + Yin ;

assign EQUAL = done ? (Sum === Xout) : 0 ;

initial
begin
    $timeformat(-9,2,"ns", 16);
    Clock = 0;
    Reset = 0;
    N = 0;
    nADD = 0;
    nADDhold = 0;
    Xin = 0;
    Yin = 0;
    flag = 4'b0;
    delay = 4'h2;
    @(posedge Clock) ;
    @(posedge Clock) ;
    Reset = 1'b1;
    @(posedge Clock) ;
    @(posedge Clock) ;
    Reset = 1'b0;

    repeat (3)
    begin
    repeat (4)
	begin
	@(posedge Clock) ;
	Xin = $random ;
	Yin = $random ;
	@(posedge Clock) ;
	@(posedge Clock)
	begin
		N = 1 ;
		nADD = $random ;
	end
	@(posedge Clock) ;
	if (flag == 1)
	begin
		repeat(2)
			@(posedge Clock);
		N = 0 ;
		nADD = 0 ;
	end
	else if (flag == 3)
	begin
		repeat(3)
			@(posedge Clock);
		N = 0 ;
		nADD = 0 ;
	end
	wait(done) ;
	if (flag == 2)
	begin
		repeat(delay)
			@(posedge Clock);
	end
	@(posedge Clock) ;
	N = 0 ;
	nADD = 0 ;
	flag = flag + 1 ;
	@(posedge Clock) ;
	end
    	repeat (2)
		@(posedge Clock) ;
	flag = 0 ;
	delay = delay + 4 ;
    end

    repeat (5)
	@(posedge Clock) ;
    nADD = 1 ; // SUB should not be asserted high
    repeat (5)
	@(posedge Clock) ;
    nADD = 0 ;
    repeat (10)
	@(posedge Clock) ;
    $stop;
end



always @(posedge nADD or posedge done or posedge Reset)
begin
	if (Reset)
		nADDhold = 0 ;
	else if (done)
	begin
		@(negedge done);
		nADDhold = 0 ;
	end
	else if (nADD & N)
		nADDhold = 1 ;
	else
		nADDhold = 0 ;
end

// 10 MHz clock
always
    #50 Clock = ~Clock ;

endmodule
