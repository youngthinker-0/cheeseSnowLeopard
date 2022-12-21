`include "lib/defines.vh"
module MEM(
    input wire clk,
    input wire rst,
    // input wire flush,
    input wire [`StallBus-1:0] stall,

    input wire [`EX_TO_MEM_WD-1:0] ex_to_mem_bus,
    input wire [31:0] data_sram_rdata,

    output wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus,
    output wire [`MEM_TO_RF_WD-1:0] mem_to_rf_bus
);

    reg [`EX_TO_MEM_WD-1:0] ex_to_mem_bus_r;

    always @ (posedge clk) begin
        if (rst) begin
            ex_to_mem_bus_r <= `EX_TO_MEM_WD'b0;
        end
        // else if (flush) begin
        //     ex_to_mem_bus_r <= `EX_TO_MEM_WD'b0;
        // end
        else if (stall[3]==`Stop && stall[4]==`NoStop) begin
            ex_to_mem_bus_r <= `EX_TO_MEM_WD'b0;
        end
        else if (stall[3]==`NoStop) begin
            ex_to_mem_bus_r <= ex_to_mem_bus;
        end
    end

    wire [31:0] mem_pc;
    wire data_ram_en;
    wire [3:0] data_ram_wen;
    wire sel_rf_res;
    wire rf_we;
    wire [4:0] rf_waddr;
    wire [31:0] rf_wdata;
    wire [31:0] ex_result;
    wire [31:0] mem_result;
    wire [65:0] hilo_bus;
    wire [7:0] ldst_op;
    wire inst_lb, inst_lbu, inst_lh, inst_lhu, inst_lw, inst_sb, inst_sh, inst_sw;

    assign {
        ldst_op,
        hilo_bus,       // 141:76
        mem_pc,         // 75:44
        data_ram_en,    // 43
        data_ram_wen,   // 42:39
        sel_rf_res,     // 38
        rf_we,          // 37
        rf_waddr,       // 36:32
        ex_result       // 31:0
    } =  ex_to_mem_bus_r;

    assign {
        inst_lb, inst_lbu, inst_lh, inst_lhu, inst_lw, inst_sb, inst_sh, inst_sw
    } = ldst_op;
    
    assign mem_result = (inst_lb & ex_result[1:0] == 2'b00) ? {{24{data_sram_rdata[7]}},data_sram_rdata[7:0]} :
                        (inst_lb & ex_result[1:0] == 2'b01) ? {{24{data_sram_rdata[15]}},data_sram_rdata[15:8]} :
                        (inst_lb & ex_result[1:0] == 2'b10) ? {{24{data_sram_rdata[23]}},data_sram_rdata[23:16]} :
                        (inst_lb & ex_result[1:0] == 2'b11) ? {{24{data_sram_rdata[31]}},data_sram_rdata[31:24]} :
                        (inst_lbu & ex_result[1:0] == 2'b00) ? {{24'b0}, data_sram_rdata[7:0]} :
                        (inst_lbu & ex_result[1:0] == 2'b01) ? {{24'b0}, data_sram_rdata[15:8]} :
                        (inst_lbu & ex_result[1:0] == 2'b10) ? {{24'b0}, data_sram_rdata[23:16]} :
                        (inst_lbu & ex_result[1:0] == 2'b11) ? {{24'b0}, data_sram_rdata[31:24]} :
                        (inst_lh & ex_result[1:0] == 2'b00) ? {{16{data_sram_rdata[15]}},data_sram_rdata[15:0]} :
                        (inst_lh & ex_result[1:0] == 2'b10) ? {{16{data_sram_rdata[31]}},data_sram_rdata[31:16]} :
                        (inst_lhu & ex_result[1:0] == 2'b00) ? {{16'b0},data_sram_rdata[15:0]} :
                        (inst_lhu & ex_result[1:0] == 2'b10) ? {{16'b0},data_sram_rdata[31:16]} :
                        inst_lw ? data_sram_rdata : 32'b0;
    assign rf_wdata = sel_rf_res ? mem_result : ex_result;

    assign mem_to_wb_bus = {
        hilo_bus,   // 135:70
        mem_pc,     // 69:38
        rf_we,      // 37
        rf_waddr,   // 36:32
        rf_wdata    // 31:0
    };

    assign mem_to_rf_bus = {
        hilo_bus,   //103:38
        rf_we,      //37
        rf_waddr,   //36:32
        rf_wdata    //31:0
    };


endmodule