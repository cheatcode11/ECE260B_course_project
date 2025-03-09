// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_8in_gated (clk, out, a_0, a_1, a_2, a_3,  a_4, a_5, a_6, a_7, b_0, b_1, b_2, b_3,  b_4, b_5, b_6, b_7, b_zero, a_zero);

parameter bw = 8;
parameter bw_psum = 2*bw+5;
parameter pr = 8; // parallel factor: number of inputs = 64

output [bw_psum-1:0] out;
//input  [pr*bw-1:0] a;
//input  [pr*bw-1:0] b;

input signed [bw-1:0] a_0;
input signed [bw-1:0] a_1;
input signed [bw-1:0] a_2;
input signed [bw-1:0] a_3;
input signed [bw-1:0] a_4;
input signed [bw-1:0] a_5;
input signed [bw-1:0] a_6;
input signed [bw-1:0] a_7;

input signed [bw-1:0] b_0;
input signed [bw-1:0] b_1;
input signed [bw-1:0] b_2;
input signed [bw-1:0] b_3;
input signed [bw-1:0] b_4;
input signed [bw-1:0] b_5;
input signed [bw-1:0] b_6;
input signed [bw-1:0] b_7;

input  clk;
input  [pr-1:0] b_zero;
input  [pr-1:0] a_zero;

wire	signed	[2*bw-1:0]	product0	;
wire	signed	[2*bw-1:0]	product1	;
wire	signed	[2*bw-1:0]	product2	;
wire	signed	[2*bw-1:0]	product3	;
wire	signed	[2*bw-1:0]	product4	;
wire	signed	[2*bw-1:0]	product5	;
wire	signed	[2*bw-1:0]	product6	;
wire	signed	[2*bw-1:0]	product7	;

reg	signed	[2*bw-1:0]	product_reg0	;
reg	signed	[2*bw-1:0]	product_reg1	;
reg	signed	[2*bw-1:0]	product_reg2	;
reg	signed	[2*bw-1:0]	product_reg3	;
reg	signed	[2*bw-1:0]	product_reg4	;
reg	signed	[2*bw-1:0]	product_reg5	;
reg	signed	[2*bw-1:0]	product_reg6	;
reg	signed	[2*bw-1:0]	product_reg7	;

genvar i;

always@(posedge clk) begin

if(b_zero[0] || a_zero[0]) product_reg0 <= {(2*bw){1'd0}};
else product_reg0 <= product0;

if(b_zero[1] || a_zero[1]) product_reg1 <= {(2*bw){1'd0}};
else product_reg1 <= product1;

if(b_zero[2] || a_zero[2]) product_reg2 <= {(2*bw){1'd0}};
else product_reg2 <= product2;

if(b_zero[3] || a_zero[3]) product_reg3 <= {(2*bw){1'd0}};
else product_reg3 <= product3;

if(b_zero[4] || a_zero[4]) product_reg4 <= {(2*bw){1'd0}};
else product_reg4 <= product4;

if(b_zero[5] || a_zero[5]) product_reg5 <= {(2*bw){1'd0}};
else product_reg5 <= product5;

if(b_zero[6] || a_zero[6]) product_reg6 <= {(2*bw){1'd0}};
else product_reg6 <= product6;

if(b_zero[7] || a_zero[7]) product_reg7 <= {(2*bw){1'd0}};
else product_reg7 <= product7;



end


assign	product0	=	{{(bw){a_0[bw-1]}},a_0}*{{(bw){b_0[bw-1]}},b_0};
assign	product1	=	{{(bw){a_1[bw-1]}},a_1}*{{(bw){b_1[bw-1]}},b_1};
assign	product2	=	{{(bw){a_2[bw-1]}},a_2}*{{(bw){b_2[bw-1]}},b_2};
assign	product3	=	{{(bw){a_3[bw-1]}},a_3}*{{(bw){b_3[bw-1]}},b_3};
assign	product4	=	{{(bw){a_4[bw-1]}},a_4}*{{(bw){b_4[bw-1]}},b_4};
assign	product5	=	{{(bw){a_5[bw-1]}},a_5}*{{(bw){b_5[bw-1]}},b_5};
assign	product6	=	{{(bw){a_6[bw-1]}},a_6}*{{(bw){b_6[bw-1]}},b_6};
assign	product7	=	{{(bw){a_7[bw-1]}},a_7}*{{(bw){b_7[bw-1]}},b_7};




assign out = 
                {{(4){product_reg0[2*bw-1]}},product_reg0	}
	+	{{(4){product_reg1[2*bw-1]}},product_reg1	}
	+	{{(4){product_reg2[2*bw-1]}},product_reg2	}
	+	{{(4){product_reg3[2*bw-1]}},product_reg3	}
	+	{{(4){product_reg4[2*bw-1]}},product_reg4	}
	+	{{(4){product_reg5[2*bw-1]}},product_reg5	}
	+	{{(4){product_reg6[2*bw-1]}},product_reg6	}
	+	{{(4){product_reg7[2*bw-1]}},product_reg7	};



endmodule

