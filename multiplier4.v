`timescale 1ns/1ns

module multiplier4
#(parameter nb = 15)
(
//-----------------------Port directions and deceleration
   input clk,  
   input start,
   input [nb-1:0] A, 
   input [nb-1:0] B, 
   output reg [nb+nb - 1:0] Product,
   output ready
    );
parameter req_bits = $clog2(nb);


//------------------------------------------------------

//----------------------------------- register deceleration
//reg [15:0] Multiplicand ;
reg [nb-1:0]  Multiplier;
reg [req_bits:0]  counter; // need to change
reg sign;
//-------------------------------------------------------

//------------------------------------- wire deceleration
wire product_write_enable;
wire [nb:0] adder_output;
wire [nb-1:0] E ;
assign E= ~A+1;
//---------------------------------------------------------

//-------------------------------------- combinational logic
assign adder_output = Multiplier + Product[nb+nb-1:nb] ;
assign product_write_enable = Product[0];
assign ready = (counter == nb); 
//---------------------------------------------------------

//--------------------------------------- sequential Logic
always @ (posedge clk)

   if(start) begin

   counter <= 0 ;
      if(B[nb-1]==0)
         Multiplier <= B;
      else Multiplier <= ~B+1;
      if(A[nb-1]==0)
         Product <= {nb*{1'b0}, A};
      else Product <= {nb*{1'b0}, E};
      
      sign <= A[nb-1]^B[nb-1];
   end
 

      else if(! ready) begin
         counter <= counter + 1;
         Product <= Product >> 1;
         if(counter == nb-1 && sign == 1)
            Product <= ~(Product >> 1) + 1;
      if(product_write_enable)begin
         Product <= {adder_output,Product[nb-1:1]};
      if(counter == nb-1 && sign == 1)
        Product <= ~{adder_output,Product[nb-1:1]} +1;
      end
   end  

endmodule