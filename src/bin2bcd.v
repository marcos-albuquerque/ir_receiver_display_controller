
module bin2bcd (
    input  wire [7:0] bin,
    output wire [11:0] bcd
  );

  wire [3:0] U0bin, U1bin, U2bin, U3bin, U4bin, U5bin, U6bin;
  wire [3:0] U0bcd, U1bcd, U2bcd, U3bcd, U4bcd, U5bcd, U6bcd;

  function [3:0] add3;
    input [3:0] bin_;
    begin
      if (bin_[3] || (bin_[2] && (bin_[1] || bin_[0])))
        add3 = bin_ + 4'd3;
      else
        add3 = bin_;
    end
  endfunction

  assign U0bin = {1'b0, bin[7:5]};
  assign U0bcd = add3(U0bin);

  assign U1bin = {U0bcd[2:0], bin[4]};
  assign U1bcd = add3(U1bin);

  assign U2bin = {U1bcd[2:0], bin[3]};
  assign U2bcd = add3(U2bin);

  assign U3bin = {U2bcd[2:0], bin[2]};
  assign U3bcd = add3(U3bin);

  assign U4bin = {U3bcd[2:0], bin[1]};
  assign U4bcd = add3(U4bin);

  assign U5bin = {1'b0, U0bcd[3], U1bcd[3], U2bcd[3]};
  assign U5bcd = add3(U5bin);

  assign U6bin = {U5bcd[2:0], U3bcd[3]};
  assign U6bcd = add3(U6bin);

  assign bcd = {2'b00, U5bcd[3], U6bcd, U4bcd, bin[0]};

endmodule
