`timescale 1ns / 1ps // 

module testbench(
    input clk,          // Basys3'ün kendi 100MHz sistem saati (W5 pini - Ekran taraması için) 
    input btnC,         // İşlemi manuel tetikleyecek buton (ALU saati - U18 pini) 
    input [15:0] sw,    // 16 adet giriş anahtarı (Switch) 
    output [3:0] an,    // 7-segment anotları 
    output [6:0] seg,   // 7-segment katotları (a,b,c,d,e,f,g) 
    output [2:0] led,   // Karşılaştırma bayraklarını (CMP) göstermek için ilk 3 LED 
    output dp           
);

    // Noktayı tamamen söndürüyoruz 
    assign dp = 1'b1; 

    
    // --- DEBOUNCE MANTIĞI EKLENDİ ---
  
    reg btnC_sync_0;
    reg btnC_sync_1;
    reg btnC_clean;
    reg [19:0] debounce_counter;

    always @(posedge clk) begin
        // 1. Asenkron butonu senkronize et (Metastability önlemi)
        btnC_sync_0 <= btnC;
        btnC_sync_1 <= btnC_sync_0;

        // 2. Sinyal stabil kalana kadar sayacı arttır
        if (btnC_sync_1 == btnC_clean) begin
            debounce_counter <= 0;
        end else begin
            debounce_counter <= debounce_counter + 1;
            // 100MHz saatte 20'hFFFFF (yaklaşık 1 milyon saykıl) ~10.4 ms gecikme yaratır.
            if (debounce_counter == 20'hFFFFF) begin 
                btnC_clean <= btnC_sync_1;
                debounce_counter <= 0;
            end
        end
    end
    // ------------------------------------------------

    // Modüller Arası Kablolar (Internal Wires) 
    wire [3:0] op; 
    wire [3:0] rd, ra, rb; 
    wire sign;
    wire [7:0] addr, w_t, alu_out;  
    wire b, e, k; 

    // CMP işlemini test ederken sonucu rahatça görmek için LED ataması 
    assign led[0] = b;  
    assign led[1] = e;  
    assign led[2] = k;  

    // 1. Kontrol Birimini  Sisteme Ekle 
    control_unit cu_inst (
        .inputs(sw),  
        .opcode(op), 
        .R_d_addr(rd), 
        .R_a_addr(ra), 
        .R_b_addr(rb),  
        .ram_addr(addr),  
        .w(w_t) 
    );

    // 2. ALU'yu Sisteme Ekle 
    alu my_alu (
        .clk(clk),
        .trigger(btnC_clean),
        .opcode(op),  
        .R_d_addr(rd),  
        .R_a_addr(ra), 
        .R_b_addr(rb), 
        .ram_addr(addr),  
        .w(w_t), 
        .sign_bit(sign), 
        .out_data(alu_out),
        .flag_B(b),  
        .flag_E(e), 
        .flag_K(k)  
    );

    // Negatif sayının mutlak değerini bul (Tersini al + 1 ekle)
    wire [7:0] abs_val = sign ? (~alu_out + 1'b1) : alu_out;
    // 4. BİNARY TO BCD DÖNÜŞTÜRÜCÜ (8-bit veriyi Yüzler, Onlar, Birler hanesine ayırma)
    reg [3:0] yuzler, onlar, birler; 
    
    always @(*) begin 
        yuzler = abs_val / 100; 
        onlar  = (abs_val % 100) / 10; 
        birler = abs_val % 10; 
    end 

    // 5. 7-SEGMENT EKRAN TARAYICI (Multiplexer) 
    // Ekranların göz kırpmaması için 100MHz'lik saati yavaşlatıyoruz 
    reg [19:0] refresh_counter = 0; 
    always @(posedge clk) begin 
        refresh_counter <= refresh_counter + 1; 
    end 
    
    wire [1:0] led_activating_counter = refresh_counter[19:18]; 
    reg [3:0] active_digit; 
    reg [3:0] an_temp;  
    
    // Hangi ekranın yanacağını ve o ekrana hangi sayının gideceğini seçiyoruz
    always @(*) begin 
        case(led_activating_counter) 
            2'b00: begin 
                an_temp = 4'b1110; 
                // En sağdaki ekran (Birler) aktif (0 aktif demektir) ]
                active_digit = birler; 
            end 
            2'b01: begin 
                an_temp = 4'b1101; 
                // Sağdan 2. ekran (Onlar) aktif 
                active_digit = onlar; 
            end 
            2'b10: begin 
                an_temp = 4'b1011; 
                // Sağdan 3. ekran (Yüzler) aktif
                active_digit = yuzler;
            end 
            2'b11: begin 
                an_temp = 4'b0111; 
                // En soldaki ekran (Kullanılmıyor, söndür) 
                active_digit = sign ? 4'b1010 : 4'b1111; 
                // Boşluk karakteri (sönük)
            end 
        endcase
    end 
    
    assign an = an_temp; 
    
    // 6. RAKAMLARI 7-SEGMENT LEDLERİNE ÇEVİRME (Decoder) 
    reg [6:0] seg_temp; 
    
    always @(*) begin 
        case(active_digit) 
            4'b0000: seg_temp = 7'b1000000; // 0
            4'b0001: seg_temp = 7'b1111001; // 1
            4'b0010: seg_temp = 7'b0100100; // 2
            4'b0011: seg_temp = 7'b0110000; // 3
            4'b0100: seg_temp = 7'b0011001; // 4
            4'b0101: seg_temp = 7'b0010010; // 5
            4'b0110: seg_temp = 7'b0000010; // 6
            4'b0111: seg_temp = 7'b1111000; // 7
            4'b1000: seg_temp = 7'b0000000; // 8
            4'b1001: seg_temp = 7'b0010000; // 9
            4'b1010: seg_temp = 7'b0111111; // -
            4'b1111: seg_temp = 7'b1111111; // bos
            default: seg_temp = 7'b1111111; // bos
        endcase 
    end
    
    assign seg = seg_temp; 

endmodule 
