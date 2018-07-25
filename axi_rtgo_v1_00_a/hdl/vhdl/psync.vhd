-- ------------------------------------------------------------------------- --
-- Title: 2-bits pulses synchronizer.                                        --
-- ------------------------------------------------------------------------- --
LIBRARY ieee;
LIBRARY unisim;
USE unisim.vcomponents.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY psync IS
   GENERIC (
      -- TRUE for synchronous reset type or FALSE for asynchronous one
      I_SYNC_RST : BOOLEAN := TRUE;                            -- Master clock reset type
      O_SYNC_RST : BOOLEAN := TRUE                             -- Slave clock reset type
   );
   PORT (
      RI : IN std_logic;                                       -- Master reset input
      RO : IN std_logic;                                       -- Slave reset input
      CI : IN std_logic;                                       -- Master clock input
      CO : IN std_logic;                                       -- Slave clock input
      O  : OUT std_logic;                                      -- Pulse output
      I  : IN std_logic                                        -- Pulse input
   );
END ENTITY psync;

ARCHITECTURE behav_arch OF psync IS
   SIGNAL sync_reg : std_logic := '0';                         -- Level synchronizer output
   SIGNAL tgle_reg : std_logic := '0';                         -- Toggle circuit register
   SIGNAL edge_reg : std_logic := '0';                         -- Edge detector register
   SIGNAL dout_reg : std_logic := '0';                         -- Output pulse register

   -- 2-bits level synchronizer
   COMPONENT lsync IS
   GENERIC (
      SYNC_RST : BOOLEAN                                       -- TRUE for synchronous reset type
                                                               -- or FALSE for asynchronous one
   );
   PORT (
      R : IN std_logic;                                        -- Reset input
      C : IN std_logic;                                        -- Clock input
      O : OUT std_logic;                                       -- Data output
      I : IN std_logic                                         -- Data input
   );
   END COMPONENT lsync;

BEGIN
   -- Toggle circuit register with synchronous reset implementation
   sync_tgle_gen : IF I_SYNC_RST GENERATE
      tgle_reg_proc : PROCESS (CI)
      BEGIN
         IF CI'EVENT AND CI = '1' THEN
            IF RI = '1' THEN
               tgle_reg <= '0';
            ELSIF I = '1' THEN
               tgle_reg <= NOT tgle_reg;
            END IF;
         END IF;
      END PROCESS tgle_reg_proc;
   END GENERATE sync_tgle_gen;
   
   -- Toggle circuit register with asynchronous reset implementation
   async_tgle_gen : IF NOT I_SYNC_RST GENERATE
      tgle_reg_proc : PROCESS (CI, RI)
      BEGIN
         IF RI = '1' THEN
            tgle_reg <= '0';
         ELSIF CI'EVENT AND CI = '1' THEN
            IF I = '1' THEN
               tgle_reg <= NOT tgle_reg;
            END IF;
         END IF;
      END PROCESS tgle_reg_proc;
   END GENERATE async_tgle_gen;

   -- 2-bits level synchronizer instantiation
   lsync_inst : lsync GENERIC MAP (SYNC_RST => O_SYNC_RST)
      PORT MAP (R => RO, C => CO, I => tgle_reg, O => sync_reg);

   -- Implementation of edge detector with synchronous reset 
   sync_edge_gen : IF O_SYNC_RST GENERATE
      edge_reg_proc : PROCESS (CO)
      BEGIN
         IF CO'EVENT AND CO = '1' THEN
            IF RO = '1' THEN
               edge_reg <= '0';
               dout_reg <= '0';
            ELSE
               edge_reg <= sync_reg;
               dout_reg <= edge_reg XOR sync_reg;
            END IF;
         END IF;
      END PROCESS edge_reg_proc;
   END GENERATE sync_edge_gen;

   -- Implementation of edge detector with asynchronous reset 
   async_edge_gen : IF NOT O_SYNC_RST GENERATE
      edge_reg_proc : PROCESS (CO, RO)
      BEGIN
         IF RO = '1' THEN
            edge_reg <= '0';
            dout_reg <= '0';
         ELSIF CO'EVENT AND CO = '1' THEN
            edge_reg <= sync_reg;
            dout_reg <= edge_reg XOR sync_reg;
         END IF;
      END PROCESS edge_reg_proc;
   END GENERATE async_edge_gen;

   -- Mapping of module outputs
   O <= dout_reg;

END ARCHITECTURE behav_arch;