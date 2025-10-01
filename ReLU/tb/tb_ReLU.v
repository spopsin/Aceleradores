`timescale 1ns / 1ps

module tb_ReLU_Nbits;

    // Parâmetro para corresponder ao do DUT (Device Under Test)
    parameter N = 4;

    // Sinais para conectar ao DUT
    reg signed [(2*N)-1:0]  tb_In;
    wire signed [N-1:0]     tb_Out;

    // Instância do seu Módulo
    ReLU_Nbits #(.N(N)) dut (
        .In(tb_In),
        .Out(tb_Out)
    );

    // Função auxiliar para testar
    task check;
        input signed [2*N-1:0] expected;
        input [127:0] msg;
        begin
        if (tb_Out !== expected)
            $error("(%s): esperado = %0b, obtido = %0b (t = %0t)", msg, expected, tb_Out, $time);
        else $display("OK (%s): valor = %0b (t = %0t)", msg, tb_Out, $time);
        msg = 0;
        end
    endtask


    // Bloco principal de testes
    initial begin
        $dumpfile("tb_ReLU_Nbits.vcd");
        $dumpvars(0, tb_ReLU_Nbits);

        $display("======================================================");
        $display("Iniciando teste da Função de Ativação Customizada");
        $display("Parâmetro N = %d-bit", N);
        $display("======================================================");

        // --- Teste 1: Bit de gatilho In[N-1] é 00000000 ---
        // A saída deve ser os N bits mais significativos de In.
      $display("\n--> Teste 1: Bit de gatilho In[%0d] = 00000000", (2*N)-1);
        tb_In = 8'b00000000; 
        #10; 
      check(4'b0000, "Teste In = 00000000");
        
        // --- Teste 2: Bit de gatilho In[N-1] é 0001 ---
        // A saída deve ser 1.
        $display("\n--> Teste 2: Bit de gatilho In[%0d] = 00000001", (2*N)-1);
        tb_In = 8'b000000001; 
        #10;
        
      check(4'b0000, "Teste In = 00000001");
        
        // --- Teste 3: Caso de Borda In[N-1] é 0101 ---
        $display("\n--> Teste 3: Bit de gatilho In[%0d] = 01010101", (2*N)-1);
        tb_In = 8'b01010101;
        #10;

      check(4'b0101, "Teste In = 01010101");

        // --- Teste 3: Caso de Borda In[N-1] é 0101 ---
        $display("\n--> Teste 3: Bit de gatilho In[%0d] = 11010101", (2*N)-1);
        tb_In = 8'b11010101;
        #10;

      check(4'b0000, "Teste In = 11010101");
        
        $display("\n======================================================");
        $display("Testes finalizados.");
        $display("======================================================");
        $finish;
    end

endmodule