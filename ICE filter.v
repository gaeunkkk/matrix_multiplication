module filter(clk, rst, data_in, data_in_valid, data_out, data_out_valid);
input   clk;
input   rst;
input [7:0]  data_in;
input  data_in_valid;
output   data_out_valid;
output [7:0] data_out;
parameter n_cols = 512;
parameter n_rows = 512;
reg [7:0] lastbuffer[2:0];
reg [7:0] linebuffer0[n_cols-1:0], linebuffer1[n_cols-1:0];
reg [7:0] data_out;
reg data_out_valid;
reg [8:0] x, y;
integer i;
reg valid[1:0];
wire [15:0] tem0,tem1,tem2,tem3,
           tem4,tem5,tem6,tem7,
           tem8;

// Keep track of input pixel's position (Sequential Logic)
// Write it below
always@(posedge clk or negedge rst) begin
	if (!rst) begin
		x <= 0; y<= 0;
	end
	else if (data_in_valid) begin
		if (x == n_cols-1) begin
			x <= 0;
			if (y == n_rows - 1) y <= 0;
			else y <= y + 1;
		end
		else x <= x + 1;
	end
end
 
 
 

// linebuffers
always@(posedge clk) begin
if(data_in_valid) begin 
linebuffer0[0] <= data_in;
for(i=0;i<n_cols-1;i=i+1)begin
linebuffer0[i+1] <= linebuffer0[i]; 
end
linebuffer1[0] <= linebuffer0[n_cols-1];
for(i=0;i<n_cols-1;i=i+1)begin
linebuffer1[i+1] <= linebuffer1[i];
end
lastbuffer[0] <= linebuffer1[n_cols-1];
lastbuffer[1] <= lastbuffer[0];
lastbuffer[2] <= lastbuffer[1];
end 
end 

// Multiply and add (Combinational logic)
// Write it below
assign tem0 = 8'd28 *linebuffer0[2];
assign tem1 = 8'd28 *linebuffer0[1];
assign tem2 = 8'd28 *linebuffer0[0];
assign tem3 = 8'd28 *linebuffer1[2];
assign tem4 = 8'd28 *linebuffer1[1];
assign tem5 = 8'd28 *linebuffer1[0];
assign tem6 = 8'd28 *lastbuffer[2];
assign tem7 = 8'd28 *lastbuffer[1];
assign tem8 = 8'd28 *lastbuffer[0];

wire [16:0] add_tem1, add_tem2, add_tem3;
assign add_tem1 = tem0 + tem1;
assign add_tem2 = tem3 + tem4;
assign add_tem3 = tem6 + tem7;
wire [17:0] add_tem4, add_tem5, add_tem6;
assign add_tem4 = add_tem1 + tem2;
assign add_tem5 = add_tem2 + tem5;
assign add_tem6 = add_tem3 + tem8;
wire [18:0] add_tem7;
assign add_tem7 = add_tem4 + add_tem5;
wire [19:0] add_tem8;
assign add_tem8 = add_tem7 + add_tem6;
always@(add_tem8) begin
data_out <= add_tem8[15:8];
end
 

// It output valid?
// Write it below
always@(posedge clk or negedge rst )begin
  if(~rst)begin
     data_out_valid <=0;
  end else if (x>=2 && y>=2) begin
     data_out_valid <=1;
  end
end
endmodule 
