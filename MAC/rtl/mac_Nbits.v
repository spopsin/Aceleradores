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

    input [N-1:0] A, B;
    output [N-1:0] S;
    output Cout;

    wire  [N-1:0] w_cout;

    // HA
    ha ha_0 (
        .a(A[0]),
        .b(B[0]),
        .s(S[0]),
        .cout(w_cout[0])
    );

    // FA
    generate
        genvar i;
        for (i = 1; i < N; i = i + 1)
            begin
                fa fa_i (
                    .a(A[i]),
                    .b(B[i]),
                    .cin(w_cout[i-1]),
                    .s(S[i]),
                    .cout(w_cout[i])
                );
            end
    endgenerate
    
    assign Cout = w_cout[N-1];
endmodule

module m_mult (W, X, Out);
    parameter N = 18;

    input [N-1:0] W, X;
    output [(2*N)-1:0] Out;

    reg [(2*N)-1:0] P;
    wire [(2*N)-1:0] PP [N-1:0];
    wire [(2*N)-1:0] P_next;
    integer i;

    // Partial Products
    generate
        genvar j;
        for (j = 0; j < N; j = j + 1)
            begin
                assign PP[j] = X[j] ? (W << j) : 0;
            end
    endgenerate

    assign P_next = P + PP[0]; // Simplified for illustration; actual implementation may vary

    assign Out = P;
endmodule

module mac_Nbits (W, X, Rst, clk, En, Out);
    parameter N = 18;

    input [N-1:0] W, X;
    input Rst, clk, En;
    output [(2*N)-1:0] Out;

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

    always @(posedge clk or posedge Rst) begin
        if (Rst) begin
            AC <= 0;
        end else if (En) begin
            AC <= out_add;
        end
    end

    assign Out = AC;
endmodule
