LAVA.v
`timescale 1ps/1ps
`define S0 3'b000
`define S1 3'b001
`define S2 3'b010
`define S3 3'b011
`define S4 3'b100
module lava(clk, rst);
input clk, rst;

reg [3:0] inst; // The "Registers"
reg [7:0] a, buswires0; // The "Registers"
reg [7:0] b, buswires1;
reg [2:0] raddr; 
reg [2:0] waddr;
reg [2:0] state; // State registers for the controller
reg we, inc;  // This is just to use always block for combinational logic
reg [2:0] next_state; // This is just to use always block for combinational logic
wire [7:0] result0;
wire [7:0] result1;
wire [7:0] q;
wire [35:0] data;

// *** Instantiate ROM, ALU, RAM here ***
rom ROM0(.a(raddr), .z(data));
alu ALU0(.Inst(inst), .A(a), .BusWires(buswires0), .DelayedResult(result0));
alu ALU1(.Inst(inst), .A(b), .BusWires(buswires1), .DelayedResult(result1));
dual_port_ram dual0(
            clk,
            waddr,result0,we,
            waddr0,result1,we,
            );
// *** Describe the behavior of the "Registers" ***
always @(posedge clk) begin
 inst <= data[35:32];
 a <= data[31:24];
 buswires0 <= data[23:16];
 b <= data[15:8];
buswires1 <= data[7:0];
end
 
// *** Program Counter, WAddr Counter ***
// Describe a sequential logic here
// Update raddr, waddr depending on rst, inc and we.
always @(posedge clk or negedge rst) begin
 if(~rst) begin
  raddr <= 3'b0;
 end else if(inc == 1'b1) begin
  raddr <= raddr + 1;
 end
end
always @(posedge clk or negedge rst) begin
 if(~rst) begin
  waddr <= 3'b0;
  waddr0 <= 3'b1;
 end else if(we == 1'b1) begin
  waddr <= waddr + 2;
  waddr <= waddr0 + 2;
 end
end
 
// ** Controller ** 
// Describe a combinational logic here
always @(state or raddr) begin
inc = 0; we = 0;
 case(state)
 `S0 : begin
  next_state = `S1;
  end
 `S1 : begin
  inc = 1;
  next_state = `S2;
  end
 `S2 : begin
  if(raddr == 3'b111) begin
   we = 1;
   next_state = `S3;
  end else if(raddr != 3'b111) begin
   we = 1;
   inc = 1;
   next_state = `S2;
  end
end
 `S3 : begin
  we = 1;
  next_state = `S4;
  end
 `S4 : next_state = `S4;
 default : ;
 endcase
end
// Describe a sequential logic for the controller
always @(posedge clk or negedge rst) begin
 if(~rst) begin
  state <= `S0;
 end else
  state <= next_state;
end

endmodule
 
dual.v
module dual_port_ram(
            clk,
            addra,dina,wea,
            addrb,dinb,web,
            );
parameter BITWIDTH = 8;
parameter ADDRWIDTH = 4;
localparam RAM_DEPTH =1<<ADDRWIDTH;
input clk;
input [ADDRWIDTH-1:0] addra;
input wea;
input [BITWIDTH-1:0] dina;
input [ADDRWIDTH-1:0] addrb;
input web;

input [BITWIDTH-1:0] dinb;
reg [BITWIDTH-1:0] mem[0:RAM_DEPTH-1];
always@(posedge clk) begin
    if(wea) begin
     mem[addra] <=dina;
     $display("mem[%d] :%d",addra,dina);
    end
    if(wea) begin
     mem[addrb] <=dinb;
     $display("mem[%d] :%d",addrb,dinb);
     end
end
endmodule
 
rom.v
`timescale 1ps/1ps
module rom(z, a);
  output [35:0] z;
  input  [2:0] a; 
  // declares a memory rom of 8 4-bit registers.
  //The indices are 0 to 7
reg    [35:0] rom[0:7]; 
wire [35:0] z;
  // NOTE:  To infer combinational logic instead of a ROM, use
  // (* synthesis, logic_block *)
 
initial $readmemb("C:\\rom.data", rom);
assign #700 z = rom[a];

endmodule
 
rom.v
`timescale 1ps/1ps
module rom(z, a);
  output [35:0] z;
  input  [2:0] a; 
  // declares a memory rom of 8 4-bit registers.
  //The indices are 0 to 7
reg    [35:0] rom[0:7]; 
wire [35:0] z;
  // NOTE:  To infer combinational logic instead of a ROM, use
  // (* synthesis, logic_block *)
 
initial $readmemb("C:\\rom.data", rom);
assign #700 z = rom[a];

endmodule
 
