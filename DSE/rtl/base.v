module neuron_intra_Nbits #(
    parameter N = 8,
    parameter N_INPUTS = 32,
    parameter LOG_N_INPUTS = 3 // log2(N_INPUTS)
) (
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         en,
    input  wire signed [N*N_INPUTS-1:0] W,    // pesos packed
    input  wire signed [N*N_INPUTS-1:0] X_N,  // entradas packed
    output reg signed [         N-1:0] Out
);

  // Resultados das multiplicações
  wire signed [2*N*N_INPUTS-1:0] prod;
  wire signed [         N-1:0] act_out;

  genvar i;
  generate
    for (i = 0; i < N_INPUTS; i = i + 1) begin : mults
      wire signed [N-1:0] Wi;
      wire signed [N-1:0] Xi;

      assign Wi = W[i*N+:N];
      assign Xi = X_N[i*N+:N];

      assign prod[i*2*N+:2*N] = Wi * Xi;
    end
  endgenerate

  // Soma de todos os produtos
  genvar j, k;
  generate
    for (j = 0; j < LOG_N_INPUTS; j = j + 1) begin : ADDER_TREE
      wire signed [2*N*(N_INPUTS >> (j+1))-1:0] sum_stage;
      if(j == 0) begin
        for (k = 0; k < (N_INPUTS >> (j+1)); k = k + 1) begin : STAGE0
          assign sum_stage[2*k*N+:2*N] = prod[2*k*2*N+:2*N] + prod[(2*k+1)*2*N+:2*N];
        end
      end else begin
        for (k = 0; k < (N_INPUTS >> (j+1)); k = k + 1) begin : STAGEJ
          assign sum_stage[2*k*N+:2*N] = ADDER_TREE[j-1].sum_stage[2*k*2*N+:2*N] + ADDER_TREE[j-1].sum_stage[(2*k+1)*2*N+:2*N];
        end
      end
    end
    wire signed [2*N-1:0] sum_all;
    assign sum_all = ADDER_TREE[LOG_N_INPUTS-1].sum_stage;
  endgenerate


  // Registrador do acumulador
  reg signed [2*N-1:0] acc;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
		acc <= 0;
		Out <= 0;
	 end
    else if (en) begin
		acc <= sum_all;
		Out <= act_out;
	 end
  end

  // ReLU Saturada
  localparam signed [N-1:0] MAX_VAL = {1'b0, {(N-1){1'b1}}}; // maior valor positivo representável em N bits
  assign act_out = (acc < 0) ? 0 : (acc > MAX_VAL) ? MAX_VAL : acc;

endmodule
