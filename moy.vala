// modules: gio-2.0 posix
// vapidirs: vapi
// sources: main.vala moy.vala

using Posix;
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

public class Moyenne
{
	public Moyenne(int puissance, int foix)
	{
		m_puissance = puissance;
		m_moy = 0.0;
		m_max = 0;
		m_foix = foix;
	}

	public string get_push_swap_string(string str_tab)
	{
		var result = "";
		int fds[2];

		pipe(fds);
		var pid = fork();
		if (pid == 0)
		{
			close(fds[0]);
			string []av = {"push_swap", str_tab};
			dup2(fds[1], 1);
			execv(@"$(push_swap_emp)", av);
			close(fds[1]);
			exit(0);
		}
		close(fds[1]);
		waitpid(pid, null, 0);
		var stream = FileStream.fdopen(fds[0], "r");

		char buf[400];
		while (stream.gets (buf) != null)
			result += (string)buf;

		close(fds[0]);
		return (result);
	}

	public string call_checker(string str, string str_tab)
	{
		int fds_out[2];
		string result;

		pipe(fds_out);

		var pid = fork();
		if (pid == 0)
		{
			close(fds_out[0]);

			dup2(fds_out[1], 1);
			printf("%s", str);

			close(fds_out[1]);
			exit(0);
		}
		waitpid(pid, null, 0);

		int fds[2];
		pipe(fds);
		close(fds_out[1]);
		var pid2 = fork();
		if (pid2 == 0)
		{
			close(fds[0]);
			close(fds_out[1]);
			string []av = {"checker_linux", str_tab};
			dup2(fds_out[0], 0);
			dup2(fds[1], 1);
			execv("checker_linux", av);
			close(fds_out[0]);
			close(fds[1]);
			exit(0);
		}
		waitpid(pid2, null, 0);
		close(fds_out[1]);
		close(fds_out[0]);
		uint8 buf[10];
		read(fds[0], &buf, 10);
		result = (string)buf;
		close(fds[0]);
		return (result);
	}
	public uint count_line(string tab)
	{
		uint	nbr = 0;
		uint	i = 0;

		var s = tab.data;
		while(s[i] != '\0')
		{
			if(s[i] == '\n')
				nbr++;
			i++;
		}
		return (nbr);
	}
	public void print_func(string? out_push, string? out_check, string tab)
	{
		uint nbr;

		nbr = this.count_line(out_push);
		add_moy(nbr);
		change_max(nbr);
		if (out_check == "OK\n")
			printf("\033[1;32m[OK] \033[0m");
		else
			printf(@"\033[1;31m[KO] {$(tab)}\033[0m");
		if (m_puissance <= 100)
		{
			if (nbr < 700)
				printf(@"Nombre de coups : $(GREEN)$(nbr)$(NONE)\n");
			else if (nbr < 900)
				printf(@"Nombre de coups : $(BLUE)$(nbr)$(NONE)\n");
			else if (nbr < 1100)
				printf(@"Nombre de coups : $(YELLOW)$(nbr)$(NONE)\n");
			else if (nbr < 1500)
				printf(@"Nombre de coups : $(ORANGE)$(nbr)$(NONE)\n");
			else
				printf(@"Nombre de coups : $(RED)$(nbr)$(NONE)\n");
		}
		else if (m_puissance <= 500)
		{
			if (nbr < 5500)
				printf(@"Nombre de coups : $(GREEN)$(nbr)$(NONE)\n");
			else if (nbr < 7000)
				printf(@"Nombre de coups : $(BLUE)$(nbr)$(NONE)\n");
			else if (nbr < 8500)
				printf(@"Nombre de coups : $(YELLOW)$(nbr)$(NONE)\n");
			else if (nbr < 11500)
				printf(@"Nombre de coups : $(ORANGE)$(nbr)$(NONE)\n");
			else
				printf(@"Nombre de coups : $(RED)$(nbr)$(NONE)\n");
		}
		else
			printf(@"Nombre de coups : \033[1m$(nbr)\033[0m\n");
	}
	public void run()
	{
		int i = 0;
		while(i < m_foix)
		{
			teste();
			i++;
		}

		if (m_puissance <= 100)
		{
			if (m_max < 700)
				printf(@"max : $(GREEN)$(m_max)$(NONE)\n");
			else if (m_max < 900)
				printf(@"max : $(BLUE)$(m_max)$(NONE)\n");
			else if (m_max < 1100)
				printf(@"max : $(YELLOW)$(m_max)$(NONE)\n");
			else if (m_max < 1500)
				printf(@"max : $(ORANGE)$(m_max)$(NONE)\n");
			else
				printf(@"max : $(RED)$(m_max)$(NONE)\n");
		}
		else if (m_puissance <= 500)
		{
			if (m_max < 5500)
				printf(@"max : $(GREEN)$(m_max)$(NONE)\n");
			else if (m_max < 7000)
				printf(@"max : $(BLUE)$(m_max)$(NONE)\n");
			else if (m_max < 8500)
				printf(@"max : $(YELLOW)$(m_max)$(NONE)\n");
			else if (m_max < 11500)
				printf(@"max : $(ORANGE)$(m_max)$(NONE)\n");
			else
				printf(@"max : $(RED)$(m_max)$(NONE)\n");
		}
		else		
			printf(@"max:\t\t$(GREEN)$(m_max)$(NONE)\n");

		m_moy /= i;
		if (m_puissance <= 100)
		{
			if (m_moy < 700)
				printf(@"moyenne : $(GREEN)$(m_moy)$(NONE)\n");
			else if (m_moy < 900)
				printf(@"moyenne : $(BLUE)$(m_moy)$(NONE)\n");
			else if (m_moy < 1100)
				printf(@"moyenne : $(YELLOW)$(m_moy)$(NONE)\n");
			else if (m_moy < 1500)
				printf(@"moyenne : $(ORANGE)$(m_moy)$(NONE)\n");
			else
				printf(@"moyenne : $(RED)$(m_moy)$(NONE)\n");
		}
		else if (m_puissance <= 500)
		{
			if (m_moy < 5500)
				printf(@"moyenne : $(GREEN)$(m_moy)$(NONE)\n");
			else if (m_moy < 7000)
				printf(@"moyenne : $(BLUE)$(m_moy)$(NONE)\n");
			else if (m_moy < 8500)
				printf(@"moyenne : $(YELLOW)$(m_moy)$(NONE)\n");
			else if (m_moy < 11500)
				printf(@"moyenne : $(ORANGE)$(m_moy)$(NONE)\n");
			else
				printf(@"moyenne : $(RED)$(m_moy)$(NONE)\n");
		
		}
		else		
			printf(@"moyenne:\t\tt$(GREEN)$(m_moy)$(NONE)\n");
	}
	public void teste()
	{
		var tab = ft_get_random_tab(m_puissance);
		var str_tab = ft_tab_to_string(tab);

		var out_push = this.get_push_swap_string(str_tab);
		var out_check = this.call_checker(out_push, str_tab);
		print_func(out_push, out_check, str_tab);
	}

	protected void change_max(uint max)
	{
		if(max > m_max)
			m_max = max;
	}

	protected void add_moy(uint nbr)
	{
		m_moy += nbr;
	}
	private int m_puissance;
	private double m_moy;
	private uint m_max;
	private int m_foix;
}

void calc_moy(string []args)
{
	var puissance = args[1] != null ? int.parse(args[1]) : 10;
	var foix = args.length > 2 ? int.parse(args[2]) : 10;
	var moyenne = new Moyenne(puissance, foix);

	moyenne.run();
	// var nbr = 0;
	// var max = 0;
	// var moy = 0.0;
	//
	// var i = 0;
	// while(i != foix)
	// {
	//     var tab = ft_get_random_tab(puissance);
	//     var str = ft_tab_to_string(tab);
	//     Posix.system(@"$(push_swap_emp) \"$(str)\" > my_file");
	//     Posix.system(@"cat ./my_file | ./checker_linux $(str) > file_check");
	//     nbr = ft_count_line();
	//     if(nbr > max)
	//         max = nbr;
	//     moy += nbr;
	// 	var FD_CHECK = FileStream.open("file_check", "r");
	// 	var s = FD_CHECK.read_line();
	// 	if (s == "OK")
	// 		stdout.printf("\033[1;32m[OK] \033[0m");
	// 	else if (s == "KO")
	// 		stdout.printf(@"\033[1;31m[KO] {$(str)}\033[0m");
	// 	stdout.printf(@"Nombre de coups : \033[1m$(nbr)\033[0m\n");
	//     i++;
	// }
	// moy /= i;
	// stdout.printf(@"max : $(GREEN)$(max)$(NONE)\n");
	// stdout.printf(@"moyenne : $(GREEN)$(moy)$(NONE)\n");
	// Posix.system("rm my_file file_check");
}
