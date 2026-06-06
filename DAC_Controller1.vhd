----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.03.2026 16:56:16
-- Design Name: 
-- Module Name: DAC_Controller1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DAC_Controller1 is
    Port ( clk50 : in STD_LOGIC;
           nRST : in STD_LOGIC;
           START : in STD_LOGIC;
           --DATA_IN : in STD_LOGIC_VECTOR (11 downto 0);
           
           wr_en    : in std_logic;
           addr_wr  : in std_logic_vector(13 downto 0);
           data_in_wr : in std_logic_vector(11 downto 0);
           
           D1 : out STD_LOGIC;
           nSYNC : out STD_LOGIC;
           CLK_OUT : out STD_LOGIC;
           DONE : out STD_LOGIC);
end DAC_Controller1;

architecture Behavioral of DAC_Controller1 is
    signal clkDiv      : std_logic;
    signal LoadData    : std_logic;
    signal enSift      : std_logic;
    signal SiftCounter : std_logic_vector(3 downto 0);
    signal DATA_READY  : std_logic;
    
    -- NUEVO: señales RAM
    signal addr_rd     : std_logic_vector(13 downto 0) := (others => '0');
    signal data_out_ram: std_logic_vector(11 downto 0);
    
    
    -- señal de addrcrl
    signal start_internal : std_logic;
    signal done_internal : std_logic;
    
        
    component clock_divider is
        Generic (
            DIV_VALUE : integer := 4 -- quedaría 1Mhz por asegurar que funcione DAC
            );
        Port (
            clk50  : in  std_logic;     -- reloj principal
            rst_in  : in  std_logic;     
            clkDiv : out std_logic      -- Reloj de salida dividada
            );
     end component;
     
     component sift_register is
      Port ( clkDiv : in STD_LOGIC;
             nRST : in STD_LOGIC;
             DATA1 : in STD_LOGIC_VECTOR (11 downto 0);
             LoadData : in STD_LOGIC;
             enSift : in STD_LOGIC;
             D1 : out STD_LOGIC;
             SiftCounter : out STD_LOGIC_VECTOR (3 downto 0));
      end component;

      component fsm is
        Port ( START : in STD_LOGIC;
             nRST : in STD_LOGIC;
             clkDiv : in STD_LOGIC;
             SiftCounter : in STD_LOGIC_VECTOR (3 downto 0);
             DATA_READY : in STD_LOGIC;
             DONE : out STD_LOGIC;
             LoadData : out STD_LOGIC;
             enSift : out STD_LOGIC;
             nSYNC : out STD_LOGIC);
      end component;
        
      component ram is
        Port ( clk      : in  STD_LOGIC;
               wr_en    : in  STD_LOGIC;
               addr_wr  : in  STD_LOGIC_VECTOR(13 downto 0);
               data_in  : in  STD_LOGIC_VECTOR(11 downto 0);
               addr_rd  : in  STD_LOGIC_VECTOR(13 downto 0);
               data_out : out STD_LOGIC_VECTOR(11 downto 0));
       end component;
       
       component AddrCtrl is 
          Port ( clkDiv : in STD_LOGIC;
                   nRST   : in STD_LOGIC;
                   DONE   : in STD_LOGIC;
                   addr_rd : out STD_LOGIC_VECTOR (13 downto 0);
                   START  : out STD_LOGIC);
       end component;
begin
    U1_Prescaler : clock_divider
       generic map (DIV_VALUE => 50)
       port map (
            clk50  => clk50,
            rst_in  => nRST,
            clkDiv => clkDiv
            );
            
    U2_FSM : fsm
      port map (
          START       => start_internal, -- cambio el  '1'START por el START para addrctrl
          nRST        => nRST,
          clkDiv      => clkDiv,
          SiftCounter => SiftCounter,
          DATA_READY  => DATA_READY,
          DONE        => done_internal, -- cambio DONE por done_internal para addrcrtl
          LoadData    => LoadData,
          enSift      => enSift,
          nSYNC       => nSYNC       
      );
      
--    U3_Sift_Register : sift_register
--      port map (
--          clkDiv      => clkDiv,
--          nRST        => nRST,
--          DATA1       => DATA_IN,
--          LoadData    => LoadData,
--          enSift      => enSift,
--          D1          => D1,
--          SiftCounter => SiftCounter  
--      );
    U4_RAM : ram
      port map (
          clk      => clk50,
          wr_en    => wr_en,
          addr_wr  => addr_wr,
          data_in  => data_in_wr,
          addr_rd  => addr_rd,
          data_out => data_out_ram
      );

    --  SIFT REGISTER (AHORA USA RAM)
    U3_Sift_Register : sift_register
      port map (
          clkDiv      => clkDiv,
          nRST        => nRST,
          DATA1       => data_out_ram, -- CAMBIO "101010101010"
          LoadData    => LoadData,
          enSift      => enSift,
          D1          => D1,
          SiftCounter => SiftCounter  
      );
      
    U5_AddrCtrl : AddrCtrl
        port map (
        clkDiv  => clkDiv,
        nRST    => nRST,
        DONE    => done_internal,
        addr_rd => addr_rd,
        START   => start_internal
    );
    
  DATA_READY <= start_internal;
    
  DONE <= done_internal;
      
  CLK_OUT <= clkDiv;

end Behavioral;
