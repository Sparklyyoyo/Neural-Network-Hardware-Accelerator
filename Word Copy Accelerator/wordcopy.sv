module wordcopy(input logic clk, input logic rst_n,
                // slave (CPU-facing)
                output logic slave_waitrequest,
                input logic [3:0] slave_address,
                input logic slave_read, output logic [31:0] slave_readdata,
                input logic slave_write, input logic [31:0] slave_writedata,
                // master (SDRAM-facing)
                input logic master_waitrequest,
                output logic [31:0] master_address,
                output logic master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
                output logic master_write, output logic [31:0] master_writedata);


    logic [31:0] destination_address;
    logic [31:0] source_address;
    logic [31:0] num_words;
    logic [31:0] words_read;
    logic [31:0] words_written;
    logic [31:0] last_word_read;
    logic [31:0] temp_read;
    logic read_flag;
    logic save_flag;
    

    enum{IDLE, READ, WAIT, WRITE} state;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            state <= IDLE;

            words_read <= 1'b0;
            words_written <= 1'b0;
            read_flag <= 1'b0;
            save_flag <= 1'b0;
            
            destination_address <= 32'b0;
            source_address <= 32'b0;
            num_words <= 32'b0;
            last_word_read <= 32'b0;
        end 
        
        else begin

            case(state)

                IDLE: begin

                    if ((slave_write === 1'b1) && (slave_address === 4'b0)) begin
                        state <= READ;
                    end

                    //else if((slave_write === 1'b1) && (slave_address === 4'b0) && (num_words > 0))
                     //   state <= WAIT;
                    
                    else
                        state <= IDLE;

                    if((slave_address === 4'd1) && (slave_write === 1'b1))
                        destination_address <= slave_writedata;
                    
                    if((slave_address === 4'd2) && (slave_write === 1'b1))
                        source_address <= slave_writedata;
                    
                    if((slave_address === 4'd3) && (slave_write === 1'b1))
                        num_words <= slave_writedata;
                    
                    words_read <= 1'b0;
                    words_written <= 1'b0;
                    read_flag <= 1'b0;
                    save_flag <= 1'b0;
                end

                READ: begin
                    
                    if(!master_waitrequest)
                        state <= WAIT;

                    else
                        state <= READ;
                    
                    if(!read_flag) begin
                        words_read <= words_read + 1;
                        read_flag <= 1'b1;
                    end
                end

                WAIT: begin

                    if (save_flag === 1'b1)
                        state <= WRITE;

                    else if(read_flag === 1'b0)
                        state <= READ;

                    else
                        state <= WAIT;

                    if(master_readdatavalid === 1'b1) begin
                        last_word_read <= master_readdata;
                        save_flag <= 1'b1;
                    end
                end

                WRITE: begin
                    
                    if(master_waitrequest === 1'b1)
                        state <= WRITE;
                    
                    else if (words_read < num_words)
                        state <= READ;
                    
                    else if(words_read === num_words) begin

                        state <= IDLE;
                    end
                    
                    else
                        state <= WAIT;
                    
                    read_flag <= 1'b0;
                    
                    if(save_flag === 1'b1) begin
                        words_written <= words_written + 1;
                        save_flag <= 1'b0;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    /* Outputs
    
    output logic slave_waitrequest
    output logic [31:0] slave_readdata
    output logic [31:0] master_address
    output logic master_read
    output logic master_write
    output logic [31:0] master_writedata
    */

    always_comb begin
        
        case(state)

            IDLE: begin
                 
                slave_waitrequest = 1'b0;
                slave_readdata = 32'b0;
                master_address = 32'b0;
                master_read = 1'b0;
                master_write = 1'b0;
                master_writedata = 32'b0;
            end

            READ: begin
                    
                slave_waitrequest = 1'b1;
                slave_readdata = 32'b0;
                master_address = source_address + (words_read - 1) * 32'd4;
                master_read = 1'b1;
                master_write = 1'b0;
                master_writedata = 32'b0;
            end

            WAIT: begin

                slave_waitrequest = 1'b1;
                slave_readdata = 32'b0;
                master_address = source_address + (words_read - 1) * 32'd4;
                master_read = 1'b0;
                master_write = 1'b0;
                master_writedata = 32'b0;
            end

            WRITE: begin

                slave_waitrequest = 1'b1;
                slave_readdata = 32'b0;
                master_address = destination_address + (words_written - 1) * 32'd4;
                master_read = 1'b0;
                master_write = 1'b1;
                master_writedata = last_word_read;
            end

            /*
            SAVE: begin

                slave_waitrequest = 1'b1;
                slave_readdata = 32'b0;
                master_address = source_address + words_written * 32'd4;
                master_read = 1'b0;
                master_write = 1'b0;
                master_writedata = 32'b0;

            end
            */

            default: begin

                slave_waitrequest = 'x;
                slave_readdata = 'x;
                master_address = 'x;
                master_read = 'x;
                master_write = 'x;
                master_writedata = 'x;
            end
        endcase
    end
endmodule: wordcopy
