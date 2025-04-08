# Homework5——fifo

## VHDL代码

### 顶层文件

```VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity fifo is
    generic(
        width : positive :=8;
        depth : positive :=8);
    port(
        clka:in std_logic;
        addra:in std_logic_vector(depth-1 downto 0);
        clkb:in std_logic;
        addrb:in std_logic_vector(depth-1 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        wr : in std_logic;
        rd : in std_logic;
        empty : out std_logic;
        full : out std_logic;
        datain:in std_logic_vector(width-1 downto 0);
        dataout:out std_logic_vector(width-1 downto 0);
        rq : in std_logic;
        wq : in std_logic;
        rd_pt : out std_logic_vector(depth-1 downto 0);
        wr_pt : in std_logic_vector(depth-1 downto 0)
        );
end fifo;

architecture Behavioral of fifo is

signal rd_pt_1:std_logic_vector(depth-1 downto 0);
signal wr_pt_1:std_logic_vector(depth-1 downto 0);
signal empty_1:std_logic;

component dualram is
generic(
    width : positive :=8;
    depth : positive :=8);
    
    port(
        clka:in std_logic;
        wr:in std_logic;
        addra:in std_logic_vector(depth-1 downto 0);
        datain:in std_logic_vector(width-1 downto 0);
        
        clkb:in std_logic;
        rd:in std_logic;
        addrb:in std_logic_vector(depth-1 downto 0);
        dataout:out std_logic_vector(width-1 downto 0)
        );
end component;

component judge_status is
    --generic(depth:positive);
    port(
        clk : in std_logic;
        rst : in std_logic;
        wr_pt : in std_logic_vector(depth-1 downto 0);
        rd_pt : in std_logic_vector(depth-1 downto 0);
        empty : out std_logic;
        full : out std_logic
    );
end component;

component read_pointer is
    --generic(depth:positive);
    port(
    clk : in std_logic;
    rst : in std_logic;
    rq : in std_logic;
    empty : in std_logic;
    rd_pt : out std_logic_vector(depth-1 downto 0)
    );
end component;

component write_pointer is
    --generic(depth : positive);
    port(
        clk : in std_logic;
        rst : in std_logic;
        wq : in std_logic;
        wr_pt : out std_logic_vector(depth-1 downto 0));
end component;

begin
    u1:dualram port map(
    clka=>clka,
    wr=>wr,
    addra=>addra,
    datain=>datain,
    clkb=>clkb,
    rd=>rd,
    addrb=>addrb,
    dataout=>dataout
    );
    
    u2:judge_status port map(
    clk=>clk,
    rst=>rst,
    wr_pt=>wr_pt_1,
    empty=>empty_1,
    rd_pt=>rd_pt_1,
    full=>full
    );
    
    u3:read_pointer port map(
    clk=>clk,
    rst=>rst,
    rq=>rq,
    empty=>empty_1,
    rd_pt=>rd_pt_1
    );
    
    u4:write_pointer port map(
    clk=>clk,
    rst=>rst,
    wq=>wq,
    wr_pt=>wr_pt_1
    );
end Behavioral;

```

### 读计数器

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity read_pointer is
    generic(depth:positive:=8);
    port(
    clk : in std_logic;
    rst : in std_logic;
    rq : in std_logic;
    empty : in std_logic;
    rd_pt : out std_logic_vector(depth-1 downto 0)
    );
end entity read_pointer;

architecture RTL of read_pointer is
signal rd_pt_t : std_logic_vector(depth-1 downto 0);
begin
    process(clk,rst)
    begin
        if rst='0' then
            rd_pt_t<=(others=>'0');
        elsif clk'event and clk='1' then
            if rq='0' and empty='0' then
                rd_pt_t<=rd_pt_t+1;
            end if;
        end if;
    end process;
    rd_pt<=rd_pt_t;
end RTL;

```

写计数器

```VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity write_pointer is
    generic(depth : positive:=8);
    port(
        clk : in std_logic;
        rst : in std_logic;
        wq : in std_logic;
        wr_pt : out std_logic_vector(depth-1 downto 0));
end entity write_pointer;

architecture RTL of write_pointer is
    signal wr_pt_t : std_logic_vector(depth-1 downto 0);
    begin
    process(rst,clk)
    begin
        if rst = '0' then
            wr_pt_t <=(others=>'0');
        elsif clk'event and clk='1' then
            if wq='0' then
                wr_pt_t<=wr_pt_t+1;
            end if;
        end if;
    end process;
    wr_pt<=wr_pt_t;
end RTL;

```

状态判断

```VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity judge_status is
    generic(depth:positive:=8);
    port(
    clk : in std_logic;
    rst : in std_logic;
    wr_pt : in std_logic_vector(depth-1 downto 0);
    rd_pt : in std_logic_vector(depth-1 downto 0);
    empty : out std_logic;
    full : out std_logic
    );
end entity judge_status;

architecture RTL of judge_status is
begin
    process(rst,clk)
    begin
        if rst='0' then
            empty<='1';
        elsif clk'event and clk='1' then
            if wr_pt =rd_pt then
                empty <='1';
            else empty<='0';
            end if;
        end if;
    end process;
    
    process(rst,clk)
    begin
        if rst='0' then
            full<='0';
        elsif clk'event and clk='1' then
            if wr_pt>rd_pt then
                if (rd_pt + depth)= wr_pt then
                    full<='1';
                else full<='0';
                end if;
            else
                if (wr_pt + 1)= rd_pt then
                    full<='1';
                else full<='0';
                end if;
            end if;
        end if;
    end process;
end RTL;

```

RAM

```VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity dualram is
    generic(
    width : positive :=8;
    depth : positive :=8);
    
    port(
        clka:in std_logic;
        wr:in std_logic;
        addra:in std_logic_vector(depth-1 downto 0);
        datain:in std_logic_vector(width-1 downto 0);
        
        clkb:in std_logic;
        rd:in std_logic;
        addrb:in std_logic_vector(depth-1 downto 0);
        dataout:out std_logic_vector(width-1 downto 0)
        );
end dualram;

architecture Behavioral of dualram is
type ram is array(2 ** depth-1 downto 0)of std_logic_vector(width-1 downto 0);
signal dualram : ram;
begin
    process(clka,clkb)
    begin
        if clka'event and clka='1' then
            if wr='0' then 
            dualram(conv_integer(addra))<=datain;
            end if;
        end if;
    end process;
    
    process(clkb)
        begin
            if clkb'event and clkb='1' then
                if rd='0' then 
                dataout<=dualram(conv_integer(addrb));
                end if;
            end if;
        end process;
end Behavioral;
```



## 激励文件

```VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use std.textio.all;
--use work.std_logic_textio.all;

entity fifo_tb is
end fifo_tb;

architecture tb_arch of fifo_tb is

    -- 定义常量
    constant WIDTH : positive := 8; -- 数据宽度
    constant DEPTH : positive := 8; -- FIFO 深度

    -- 时钟信号
    signal clk : std_logic := '0';

    -- 重置信号
    signal rst : std_logic := '0';

    -- 读写使能信号
    signal wr : std_logic := '0';
    signal rd : std_logic := '0';

    -- FIFO 地址信号
    signal addra : std_logic_vector(DEPTH-1 downto 0) := (others => '0');
    signal addrb : std_logic_vector(DEPTH-1 downto 0) := (others => '0');

    -- FIFO 数据信号
    signal datain : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal dataout : std_logic_vector(WIDTH-1 downto 0);

    -- FIFO 状态信号
    signal empty : std_logic:='1';
    signal full : std_logic:='0';

    -- 读写指针信号
    signal rq : std_logic := '0';
    signal wq : std_logic := '0';
    signal rd_pt : std_logic_vector(DEPTH-1 downto 0):= (others => '0');
    signal wr_pt : std_logic_vector(DEPTH-1 downto 0):= (others => '0');
    
component fifo is
    generic(
        width : positive :=8;
        depth : positive :=8);
    port(
        clka:in std_logic;
        addra:in std_logic_vector(depth-1 downto 0);
        clkb:in std_logic;
        addrb:in std_logic_vector(depth-1 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        wr : in std_logic;
        rd : in std_logic;
        empty : out std_logic;
        full : out std_logic;
        datain:in std_logic_vector(width-1 downto 0);
        dataout:out std_logic_vector(width-1 downto 0);
        rq : in std_logic;
        wq : in std_logic;
        rd_pt : out std_logic_vector(depth-1 downto 0);
        wr_pt : in std_logic_vector(depth-1 downto 0)
    );
    end component;

begin
    -- 连接待测试的 FIFO 模块
    dut : fifo port map(
            clka => clk,
            addra => addra,
            clkb => clk,
            addrb => addrb,
            clk => clk,
            rst => rst,
            wr => wr,
            rd => rd,
            empty => empty,
            full => full,
            datain => datain,
            dataout => dataout,
            rq => rd,
            wq => wr,
            rd_pt => rd_pt,
            wr_pt => wr_pt
        );

    -- 时钟过程
    clk_process : process
    begin
        while now < 1000 ns loop
            clk <= not clk;
            wait for 5 ns;
        end loop;
        wait;
    end process clk_process;

    -- 重置过程
    reset_process : process
    begin
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        --wait;
        wait for 10 ns;
    end process reset_process;

    -- 写入过程
    write_process : process
    begin
        wait until rising_edge(clk);
        wr <= '0';
        --wq <= '0';
        addra <= "00000001"; -- 写入地址
        datain <= "00000000"; -- 写入数据
        wait for 10 ns;
        addra <= "00000010";
        datain <= "00000001";
        wait for 10 ns;
        addra <= "00000100";
        datain <= "00000010";
        wait for 10 ns;
        addra <= "00001000";
        datain <= "00000011";
        wait for 10 ns;
        addra <= "00010000"; 
        datain <= "00000100"; 
        wait for 10 ns;
        addra <= "00100000";
        datain <= "00000101";
        wait for 10 ns;
        addra <= "01000000";
        datain <= "00000110";
        wait for 10 ns;
        addra <= "10000000";
        datain <= "00000111";
        wait for 10 ns;
        wr <= '1';
        --wq <= '1';
    end process write_process;

    -- 读取过程
    read_process : process
    begin
        wait until rising_edge(clk);
        rd <= '1';
        --rq <= '1';
        wait for 10 ns;
        rd <= '0';
        addrb <= "00000001";
        wait for 10 ns;
        addrb <= "00000010";
        wait for 10 ns;
        addrb <= "00000100";
        wait for 10 ns;
        addrb <= "00001000"; -- 读取地址
        wait for 10 ns;
        addrb <= "00010000";
        wait for 10 ns;
        addrb <= "00100000";
        wait for 10 ns;
        addrb <= "01000000";
        wait for 10 ns;
        addrb <= "10000000"; -- 读取地址
        wait for 10 ns;
        rd <= '1';
        --rq <= '1';
    end process read_process;

end tb_arch;

```



## 仿真结果

![image-20240405211016554](D:\西电\soc微体系设计\homework\image-20240405211016554.png)

![image-20240405211044692](D:\西电\soc微体系设计\homework\image-20240405211044692.png)