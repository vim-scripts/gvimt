BEGIN {
    if (ARGV[1]=="t") 
            system("start gvim --remote-send \":tablast | tabe " ARGV[2] "<CR>\"")
    else if (ARGV[1]=="v")
            system("start gvim --remote-send \":vsplit " ARGV[2] "<CR>\"")
    else if (ARGV[1]=="s")
            system("start gvim --remote-send \":split " ARGV[2] "<CR>\"");
}
