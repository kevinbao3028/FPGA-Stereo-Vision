	component video_pll2 is
		port (
			ref_clk_clk        : in  std_logic := 'X'; -- clk
			ref_reset_reset    : in  std_logic := 'X'; -- reset
			video_in_clk_clk   : out std_logic;        -- clk
			reset_source_reset : out std_logic         -- reset
		);
	end component video_pll2;

	u0 : component video_pll2
		port map (
			ref_clk_clk        => CONNECTED_TO_ref_clk_clk,        --      ref_clk.clk
			ref_reset_reset    => CONNECTED_TO_ref_reset_reset,    --    ref_reset.reset
			video_in_clk_clk   => CONNECTED_TO_video_in_clk_clk,   -- video_in_clk.clk
			reset_source_reset => CONNECTED_TO_reset_source_reset  -- reset_source.reset
		);

