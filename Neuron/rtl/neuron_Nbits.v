module ha(a, b, s, cout);
    input a, b; 
    output s, cout;

    assign s = a ^ b;        
    assign cout = a & b;     

endmodule

module fa(a, b, cin, s, cout);
    input a, b, cin; 
    output s, cout;
    wire c1, c2;

    assign s = a ^ b ^ cin;
    assign c1 = a & b;
    assign c2 = (a ^ b) & cin;
    assign cout = c1 | c2;
endmodule


module rca_Nbits (A, B, S, Cout);
    parameter N = 16;

    input signed [N-1:0] A, B;
    output signed [N-1:0] S;
    output Cout;

//     wire  [N-1:0] w_cout;

//     // HA
//     ha ha_0 (
//         .a(A[0]),
//         .b(B[0]),
//         .s(S[0]),
//         .cout(w_cout[0])
//     );

//     // FA
//     generate
//         genvar i;
//         for (i = 1; i < N; i = i + 1)
//             begin
//                 fa fa_i (
//                     .a(A[i]),
//                     .b(B[i]),
//                     .cin(w_cout[i-1]),
//                     .s(S[i]),
//                     .cout(w_cout[i])
//                 );
//             end
//     endgenerate
    
//     assign Cout = w_cout[N-1];
  assign S = A + B;
  
endmodule

module m_mult (W, X, Out);
    parameter N = 18;

    input signed [N-1:0] W, X;
    output signed [(2*N)-1:0] Out;

//     reg [(2*N)-1:0] P;
//     wire [(2*N)-1:0] PP [N-1:0];
//     wire [(2*N)-1:0] P_next;
//     integer i;

//     // Partial Products
//     generate
//         genvar j;
//         for (j = 0; j < N; j = j + 1)
//             begin
//                 assign PP[j] = X[j] ? (W << j) : 0;
//             end
//     endgenerate

//     assign P_next = P + PP[0]; // Simplified for illustration; actual implementation may vary

//     assign Out = P;
  assign Out = W * X;
  
endmodule

module mac_Nbits (W, X, rst, clk, en, Out);
    parameter N = 18;

    input signed [N-1:0] W, X;
    input rst, clk, en;
    output signed [(2*N)-1:0] Out;

    wire [(2*N)-1:0] out_mult, out_add;

    reg [(2*N)-1:0] AC;

    m_mult #(N) m_mult_inst (
        .W(W),
        .X(X),
        .Out(out_mult)
    );

    rca_Nbits #(2*N) rca_inst (
        .A(out_mult),
        .B(AC),
        .S(out_add[(2*N)-1:0]),
        .Cout()
    );

  always @(posedge clk or posedge rst) begin
    if (!rst) begin
            AC <= 0;
    end else if (en) begin
            AC <= out_add;
        end
    end

    assign Out = AC;
endmodule

module ReLU_Nbits (In, Out);
    parameter N = 18;

    input signed [(2*N)-1:0] In;
    output reg [N-1:0] Out;

    always @(*) begin
        if (In[(2*N)-1] == 1'b1) begin
            Out = 0;
        end else begin
            Out = In[(2*N)-1:N];
        end
    end
endmodule



module neuron_Nbits (W, X, clk, rst, en, Out);
    parameter N = 18;

    input [N-1:0] W, X; // Entradas
    input clk, rst, en;
    output [N-1:0] Out; // Saída da ativação

    wire [(2*N)-1:0] mac_out;

    mac_Nbits #(N) mac_inst (
        .W(W),
        .X(X),
        .rst(rst),
        .clk(clk),
        .en(en),
        .Out(mac_out)
    );

    ReLU_Nbits #(N) relu_inst (
        .In(mac_out),
        .Out(Out)
    );
  
     
endmodule