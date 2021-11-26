module Registers(
    input		     clock,
    input		     reset,
    input		     newhex, // High when a hexidecimal number is pressed
    input [3:0]		     hexcode, // The hexidecimal number currently pressed
    input		     newop, // High when an operator is pressed
    input		     eq, // Equals is currently being pressed
    input		     BS, // Backspace key
    input signed [16:0]	     answer,        //Sign and magnitude
    output reg signed [16:0] V1curr,        //Sign and magnitude
    output reg signed [16:0] V2curr         //Sign and magnitude
    );              

   reg signed [16:0]	     V1next, V2next;   //Sign and magnitude
   reg			     FLOWMODEcurr, FLOWMODEnext;

   wire [16:0]		     overwrite;
   assign overwrite = {13'd0, hexcode};
    
   // Reset condition

   always @ (posedge clock)
     begin   
        if (reset)
          begin   
             V1curr <= 17'h0000;
             V2curr <= 17'h0000;
             FLOWMODEcurr <=1'b0;
          end 
        else 
          begin
             V1curr <= V1next;
             V2curr <= V2next;
             FLOWMODEcurr <= FLOWMODEnext;
          end    
     end 
   
   //Flow Mode Module
   always @ (FLOWMODEcurr)
     begin
        if (newhex)             FLOWMODEnext <= 1'b0;
        else if (eq | newop)    FLOWMODEnext <= 1'b1;
        else                    FLOWMODEnext <= FLOWMODEcurr;
     end
   
   // V1 Instructions
   always @ (V1curr)
     begin
        if (eq)                             V1next <= answer;
        else if (FLOWMODEcurr && newhex)    V1next <= overwrite; // only overwrite if we get a new char
        else if (BS)                        V1next <= {4'b0, V1curr[15:4]}; // shift right is backspace
        else                                V1next <= {V1curr[16],V1curr[11:0], hexcode}; // shift left
     end
  
   // V2 Instructions
   always @ (V2curr)
     begin
        if (newhex | eq)    V2next <= V1curr;
        else                V2next <=V2curr;
     end
   
endmodule
