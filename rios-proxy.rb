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
  end

  class Proxy
    BUFSIZE = 128

    def initialize
      @fd_master, @fd_slave = PTY.openpty
      @get_filters = []
      @post_filters = []
    end

    def get(&block)
      @get_filters.push(block)
    end

    def post(&block)
      @post_filters.push(block)
    end

    def make_raw(termios)
      termios.c_iflag &= ~(Termios::IGNBRK | Termios::BRKINT | Termios::PARMRK |
                           Termios::ISTRIP | Termios::INLCR | Termios::IGNCR |
                           Termios::ICRNL | Termios::IXON);
      # termios.c_oflag &= ~Termios::OPOST;
      termios.c_lflag &= ~(Termios::ECHONL |
                           Termios::ICANON |
                           Termios::ISIG | Termios::IEXTEN);
      termios.c_cflag &= ~(Termios::CSIZE | Termios::PARENB);
      termios.c_cflag |= Termios::CS8;
      termios.c_lflag &= ~Termios::ECHO;
    end

    def in_raw_mode
      old_tt = Termios.tcgetattr($stdin)
      raw_tt = old_tt.clone

      begin
        make_raw(raw_tt)
        Termios.tcsetattr($stdin, Termios::TCSAFLUSH, raw_tt)
        yield
      ensure
        Termios.tcsetattr($stdin, Termios::TCSAFLUSH, old_tt)
      end
    end

    def create_terminal
      Terminal.new(@fd_master, @fd_slave)
    end

    def listen
      in_raw_mode do
        fork do
          fork do
            do_command
          end
          do_output
        end
        do_input
      end
    end

    def do_input
      terminal = create_terminal

      terminal.slave.close

      begin
        while s = $stdin.sysread(BUFSIZE) do
          @get_filters.each { |filter| filter.call(s) }
          terminal.master.syswrite(s)
        end
      rescue EOFError
      end
    end

    def do_output
      terminal = create_terminal

      $stdout.sync = true
      $stdin.close
      terminal.slave.close

      begin
        while s = terminal.master.sysread(BUFSIZE) do
          @post_filters.each { |filter| filter.call(s) }
          $stdout.syswrite(s)
        end
      rescue
      end
    end

    def do_command
      terminal = create_terminal

      terminal.master.close
      $stdin.reopen(terminal.slave)
      $stdout.reopen(terminal.slave)
      $stderr.reopen(terminal.slave)
      terminal.slave.close

      exec("/usr/bin/zsh")
    end
  end
end
