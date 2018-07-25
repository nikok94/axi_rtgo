-- ------------------------------------------------------------------------- --
-- Title: 2-bits level synchronizer.                                         --
-- ------------------------------------------------------------------------- --
LIBRARY ieee;
LIBRARY unisim;
USE unisim.vcomponents.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY lsync IS
   GENERIC (
      SYNC_RST : BOOLEAN := FALSE                              -- TRUE for synchronous reset type
                                                               -- or FALSE for asynchronous one
   );
   PORT (
      R : IN std_logic;                                        -- Reset input
      C : IN std_logic;                                        -- Clock input
      O : OUT std_logic;                                       -- Data output
      I : IN std_logic                                         -- Data input
   );
END ENTITY lsync;

ARCHITECTURE rtl_arch OF lsync IS
   SIGNAL sreg : std_logic_vector(1 DOWNTO 0);                 -- Synchronizer registers
BEGIN
   -- Registers with synchronous reset instantiation
   sync_rst_gen : IF SYNC_RST GENERATE
      -- Place synchronizer registers in the same slice
      ATTRIBUTE HBLKNM : STRING;
      ATTRIBUTE HBLKNM OF sreg0_inst : LABEL IS "LSYNC_REG";
      ATTRIBUTE HBLKNM OF sreg1_inst : LABEL IS "LSYNC_REG";
   BEGIN
      sreg0_inst : FDCE GENERIC MAP (INIT => '0')
         PORT MAP (C => C, CLR => R, CE => '1', D => I, Q => sreg(0));
      sreg1_inst : FDCE GENERIC MAP (INIT => '0')
         PORT MAP (C => C, CLR => R, CE => '1', D => sreg(0), Q => sreg(1));
   END GENERATE sync_rst_gen;

   -- Registers with asynchronous reset instantiation
   async_rst_gen : IF NOT SYNC_RST GENERATE
      ATTRIBUTE HBLKNM : STRING;
      ATTRIBUTE HBLKNM OF sreg0_inst : LABEL IS "LSYNC_REG";
      ATTRIBUTE HBLKNM OF sreg1_inst : LABEL IS "LSYNC_REG";
   BEGIN
      sreg0_inst : FDRE GENERIC MAP (INIT => '0')
         PORT MAP (C => C, R => R, CE => '1', D => I, Q => sreg(0));
      sreg1_inst : FDRE GENERIC MAP (INIT => '0')
         PORT MAP (C => C, R => R, CE => '1', D => sreg(0), Q => sreg(1));
   END GENERATE async_rst_gen;

   -- Mapping of module outputs
   O <= sreg(1);

END ARCHITECTURE rtl_arch;