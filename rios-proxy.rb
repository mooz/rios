require "rubygems"
require "termios"
require "openpty"

module Rios
  class Terminal
    def initialize(fd_master, fd_slave)
      @fd_master, @fd_slave = fd_master, fd_slave
    end

    def synced(io)
      io.sync = true unless io.closed?
      io
    end

    def master
      synced(@master ||= IO.open(@fd_master))
    end

    def slave
      synced(@slave ||= IO.open(@fd_slave))
    end

    class << self
      def set_raw_mode(termios)
        termios.c_iflag &= ~(Termios::IGNBRK | Termios::BRKINT |
                             Termios::PARMRK | Termios::ISTRIP |
                             Termios::INLCR  | Termios::IGNCR  |
                             Termios::ICRNL  | Termios::IXON)
        termios.c_oflag &= ~Termios::OPOST
        termios.c_lflag &= ~(Termios::ECHO   | Termios::ECHONL |
                             Termios::ICANON | Termios::ISIG   |
                             Termios::IEXTEN)
        termios.c_cflag &= ~(Termios::CSIZE  | Termios::PARENB)
        termios.c_cflag |= Termios::CS8
      end
    end
  end

  class Proxy
    BUFSIZE = 128
    DEFAULT_COMMAND = ENV["SHELL"]

    def initialize
      @fd_master, @fd_slave = PTY.openpty($stdin.fileno)
      @input_filters = []
      @output_filters = []
      @on_finishes = []
    end

    def on_input(&block)
      @input_filters.push(block)
    end

    def on_output(&block)
      @output_filters.push(block)
    end

    def on_finish(&block)
      @on_finishes.push(block)
    end

    def listen(command = nil, &block)
      @command = command || DEFAULT_COMMAND

      in_raw_mode {
        fork {
          fork {
            do_command(block)
          }
          do_output()
        }
        Signal.trap(:CHLD) { terminal.master.close() }
        do_input()
      }
    end

    def in_raw_mode
      old_tt = Termios::tcgetattr($stdin)
      raw_tt = old_tt.clone

      begin
        Terminal::set_raw_mode(raw_tt)
        raw_tt.c_lflag &= ~Termios::ECHO
        Termios.tcsetattr($stdin, Termios::TCSAFLUSH, raw_tt)
        yield
      ensure
        Termios.tcsetattr($stdin, Termios::TCSAFLUSH, old_tt)
      end
    end

    def create_terminal
      Terminal.new(@fd_master, @fd_slave)
    end

    def terminal
      @terminal || @terminal = create_terminal
    end

    def do_input
      terminal.slave.close

      begin
        while s = $stdin.sysread(BUFSIZE) do
          @input_filters.each { |filter| filter.call(s) }
          terminal.master.syswrite(s)
        end
      rescue
      end

      @on_finishes.each { |block| block.call }
    end

    def do_output
      $stdout.sync = true
      $stdin.close
      terminal.slave.close

      begin
        while s = terminal.master.sysread(BUFSIZE) do
          filtered = @output_filters.reduce(s) { |acc, output_filter|
            res = output_filter.call(acc)
            res.nil? ? res : acc
          }
          $stdout.syswrite(filtered)
        end
      rescue
      end

      terminal.master.close
    end

    def do_command(block)
      terminal.master.close
      $stdin.reopen(terminal.slave)
      $stdout.reopen(terminal.slave)
      $stderr.reopen(terminal.slave)
      terminal.slave.close

      if block
        block.call
      else
        exec(@command)
      end
    end
  end
end
