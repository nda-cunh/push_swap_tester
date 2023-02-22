//valac moy.vala main.vala --pkg=posix --vapidir=./vapi 
const string GREEN = "\033[1;92m";
const string BLUE = "\033[1;36m";
const string YELLOW = "\033[1;93m";
const string ORANGE = "\033[1;91m";
const string RED = "\033[1;31m";
const string NONE = "\033[0m";

int[] ft_get_random_tab(int size)
{
    var tab = new int[size];
    var n = 0;
    
    for (var i = 0; i != size; i++)
    {
        n = Random.int_range(int.MIN, int.MAX);
        if (n in tab)
            i--;
        else
            tab[i] = n;
    }
    return (tab);
}

string ft_tab_to_string(int []tab)
{
    var str = "";
    foreach (var i in tab)
        str += i.to_string() + " ";
    return(str);
}

string ft_count_line(int fd_in, out int nb)
{
    var fd = FileStream.fdopen (fd_in, "r");
	var str = fd.read_all();
   
	var split = str.split("\n");
	nb = split.length;

	return (str);
}

int run_exec(string str, out int nbr){
	int fds[2];
	int pid;

	Posix.pipe(fds);
	pid = Posix.fork();
	if (pid == 0){
		Posix.dup2(fds[1], 1);
		Posix.close(fds[0]);
		Posix.execv(push_swap_emp, {"push_swap", @"$str"});
	}
	else
		Posix.close(fds[1]);
	var str_push = ft_count_line(fds[0], out nbr);
	Posix.close(fds[0]);
	Posix.pipe(fds);
	pid = Posix.fork();
	if (pid == 0){
		Posix.dup2(fds[1], 1);
		Posix.close(fds[0]);
		stdout.printf("%s", str_push);
		Posix.exit(0);
	}
	else
		Posix.close(fds[1]);
	return (fds[0]);
}

string run_push_swap(string str, out int nbr){
	int pid;
	int fds_out[2];
	int fd_in;

	fd_in = run_exec(str, out nbr);
	Posix.pipe(fds_out);
	pid = Posix.fork();
	if (pid == 0){
		Posix.dup2(fd_in, 0);
		Posix.close(fds_out[0]);
		Posix.dup2(fds_out[1], 1);
		Posix.execv("./checker_linux", {"checker_linux", @"$str"});
	}
	else{
		Posix.close(fds_out[1]);
		Posix.close(fd_in);
	}
	Posix.waitpid(-1, null, 0);
	Posix.waitpid(-1, null, 0);
	uint8 buf[42];
	var x = Posix.read(fds_out[0], buf, 42);
	buf[x] = '\0';
	Posix.close(fds_out[0]);
	return ((string)buf);
}


void calc_moy(string []args)
{
    var puissance = args[1] != null ? int.parse(args[1]) : 10;
    var foix = args.length > 2 ? int.parse(args[2]) : 10;
    var nbr = 0;
    var max = 0;
    var moy = 0.0;

    var i = 0;
    while(i != foix)
    {
        var tab = ft_get_random_tab(puissance);
        var str = ft_tab_to_string(tab).strip();

		var s = run_push_swap(str, out nbr);

        if(nbr > max)
            max = nbr;
        moy += nbr;
		if (s == "OK\n")
			stdout.printf("\033[1;32m[OK] \033[0m");
		else if (s == "KO\n")
			stdout.printf(@"\033[1;31m[KO] {$(str)}\033[0m");
        if (puissance <= 100)
		{
			if (nbr < 700)
				stdout.printf(@"Nombre de coups : $(GREEN)$(nbr)$(NONE)\n"); 
			else if (nbr < 900)
				stdout.printf(@"Nombre de coups : $(BLUE)$(nbr)$(NONE)\n"); 
			else if (nbr < 1100)
				stdout.printf(@"Nombre de coups : $(YELLOW)$(nbr)$(NONE)\n"); 
			else if (nbr < 1500)
				stdout.printf(@"Nombre de coups : $(ORANGE)$(nbr)$(NONE)\n"); 
			else
				stdout.printf(@"Nombre de coups : $(RED)$(nbr)$(NONE)\n"); 
		}
		else if (puissance <= 500)
		{
			if (nbr < 5500)
				stdout.printf(@"Nombre de coups : $(GREEN)$(nbr)$(NONE)\n"); 
			else if (nbr < 7000)
				stdout.printf(@"Nombre de coups : $(BLUE)$(nbr)$(NONE)\n"); 
			else if (nbr < 8500)
				stdout.printf(@"Nombre de coups : $(YELLOW)$(nbr)$(NONE)\n");
			else if (nbr < 11500)
				stdout.printf(@"Nombre de coups : $(ORANGE)$(nbr)$(NONE)\n");
			else
				stdout.printf(@"Nombre de coups : $(RED)$(nbr)$(NONE)\n");
		}
		else
			stdout.printf(@"Nombre de coups : \033[1m$(nbr)\033[0m\n");
        i++;
    }
	if (puissance <= 100)
	{
		if (max < 700)
			stdout.printf(@"max : $(GREEN)$(max)$(NONE)\n");
		else if (max < 900)
			stdout.printf(@"max : $(BLUE)$(max)$(NONE)\n");
		else if (max < 1100)
			stdout.printf(@"max : $(YELLOW)$(max)$(NONE)\n");
		else if (max < 1500)
			stdout.printf(@"max : $(ORANGE)$(max)$(NONE)\n");
		else
			stdout.printf(@"max : $(RED)$(max)$(NONE)\n");
	}
	else if (puissance <= 500)
	{
		if (max < 5500)
			stdout.printf(@"max : $(GREEN)$(max)$(NONE)\n");
		else if (max < 7000)
			stdout.printf(@"max : $(BLUE)$(max)$(NONE)\n");
		else if (max < 8500)
			stdout.printf(@"max : $(YELLOW)$(max)$(NONE)\n");
		else if (max < 11500)
			stdout.printf(@"max : $(ORANGE)$(max)$(NONE)\n");
		else
			stdout.printf(@"max : $(RED)$(max)$(NONE)\n");
	}
	else		
		stdout.printf(@"maxenne : $(GREEN)$(max)$(NONE)\n");

	moy /= i;
	if (puissance <= 100)
	{
		if (moy < 700)
			stdout.printf(@"moyenne : $(GREEN)$(moy)$(NONE)\n");
		else if (moy < 900)
			stdout.printf(@"moyenne : $(BLUE)$(moy)$(NONE)\n");
		else if (moy < 1100)
			stdout.printf(@"moyenne : $(YELLOW)$(moy)$(NONE)\n");
		else if (moy < 1500)
			stdout.printf(@"moyenne : $(ORANGE)$(moy)$(NONE)\n");
		else
			stdout.printf(@"moyenne : $(RED)$(moy)$(NONE)\n");
	}
	else if (puissance <= 500)
	{
		if (moy < 5500)
			stdout.printf(@"moyenne : $(GREEN)$(moy)$(NONE)\n");
		else if (moy < 7000)
			stdout.printf(@"moyenne : $(BLUE)$(moy)$(NONE)\n");
		else if (moy < 8500)
			stdout.printf(@"moyenne : $(YELLOW)$(moy)$(NONE)\n");
		else if (moy < 11500)
			stdout.printf(@"moyenne : $(ORANGE)$(moy)$(NONE)\n");
		else
			stdout.printf(@"moyenne : $(RED)$(moy)$(NONE)\n");
	}
	else		
		stdout.printf(@"moyenne : $(GREEN)$(moy)$(NONE)\n");
	Posix.system("rm -rf my_file file_check");
}
