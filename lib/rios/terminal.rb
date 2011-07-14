require "rubygems"
require "termios"

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
end
