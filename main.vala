using Posix;

string ft_getline(int fd)
{
	var res = "";
	char b = '0';

	while (read(fd, &b, 1) > 0)
	{
		res += @"$b";
		if(b == '\n')
			return (res);
	}
	return (res);
}

public string push_swap_emp;

enum ONLY{
	ALL, TRUE, FALSE, MEMORY_LEAK
}
ONLY g_only = ALL;
void list_test()
{
	/* TRUE = GOOD  */
	/* FALSE = ERROR */

	test({"52"}, true);
	test({"5", "4", "3"}, true);
	test({"5", "1", "0", "2"}, true);
	test({"5 4A 3"}, false);
	test({"5 2 3 4 8"}, true);
	test({"42 -500 -2845 -21 54784 1541"}, true);
	test({"42", "500", "-2845", "-21", " 54784", "1541"}, true);
	test({"52 14 15"}, true);
	test({"e1 2 3 4 5"}, false);
	test({"1 2 4 3 5e"}, false);
	test({"1 2 3 4 5e"}, false);
	test({"+", "52"}, false);
	test({"1 2 3"}, true);
	test({" 1 2 3"}, true);
	test({"1 2 3 "}, true);
	test({" 1 2 3 "}, true);
	test({" 1   2               3 "}, true);
	test({"1 2 3 4 5"}, true);
	test({"5 4 3 2 1"}, true);
	test({"5", "3", "2", "1"}, true);
	test({" 5", "3  ", " 2", " 1"}, true);
	test({" 5", "8"}, true);
	test({"05 02"}, true);
	test({"2147483647 -2147483648"}, true);
	test({"0002147483647 -002147483648"}, true);
	test({"05 08 0009 00010 2"}, true);
	test({"05 5 005"}, false);
	test({"-00", "00"}, false);
	test({"052 02"}, true);
	test({"-0", "0"}, false);
	test({"0", "-0"}, false);
	test({"-10", "-23"}, true);
	test({"-0"}, true);
	test({"4 2 3", "5"}, true);
	test({"5", "4", "3"}, true);
	test({"10 5 4 2 1 3 6 9"}, true);
	test({"5-2"}, false);
	test({"5+2"}, false);
	test({"2-5"}, false);
	test({"2+5"}, false);
	test({"2", "", "3"}, false);
	test({"3", "", "2"}, false);
	test({"   ", " ", "   "}, false);
	test({"   ", "-", "   "}, false);
	test({"   ", "-a", "   "}, false);
	test({"   -a   "}, false);
	test({"++52"}, false);
	test({"+-52"}, false);
	test({"9 2147483648 5"}, false);
	test({"9 -2147483649 8"}, false);
	test({"9 214748364842 5"}, false);
	test({"9 -21474836494 8"}, false);
	test({"8 -214748364945465565656"}, false);
	test({"25 514748364945465565656"}, false);

	Posix.system("rm -rf tmp_1 tmp_2 tmp_3");
}

void test(string[] arg, bool compare)
{
	var tab = tab_to_string(arg);
	FileStream FD_ERR;
	FileStream FD_OUT;
	string str;

	if (g_only == MEMORY_LEAK)
	{
		string []av = { "valgrind", @"$(push_swap_emp)"};
		string []split_line = null;
		string line = null;
		string x = null;
		string y = null;
		int fds[2];
		
		pipe(fds);
		var pid = fork();
		if(pid == 0)
		{
			foreach(var i in arg)
				av += @"$i";
			close(fds[0]);
			close(1);
			dup2(fds[1], 2);
			execvp("/bin/valgrind", av);
			close(fds[1]);
		}
		waitpid(pid, null, 0);
		close(fds[1]);
		do{
			line = ft_getline(fds[0]);
			if (line != null && "total" in line)
			{
				split_line = line.split(" ");
				break ;
			}
		}while (line != null);
		x = split_line[6];
		y = split_line[8];
		if(x == y)
			printf(@"\033[1;32m[MOK]:$(GREEN) $x malloc, $y free$(NONE)\n");
		else
			printf(@"$(RED)[MKO]: $x malloc , $y free { $(tab)}$(NONE)\n");
		close(fds[0]);
		return ;
	}
	Posix.system(@"$(push_swap_emp) $(tab) 1>tmp_1  2> tmp_2");
	FD_ERR = FileStream.open("tmp_2", "r");
	str = FD_ERR.read_line();
	if (compare == false)
	{
		if (g_only == TRUE)
			return ;
		if (str == "Error")
			printf("\033[1;32mOK \033[0m");
		else
			printf("\033[1;31mKO [ %s] \033[0m", tab);
	}
	else
	{
		if (g_only == FALSE)
			return ;
		Posix.system(@"cat tmp_1 | ./checker_linux 2> /dev/null $(tab) > tmp_3");
		FD_OUT = FileStream.open("tmp_3", "r");
		str = FD_OUT.read_line();
		if (str != null && "OK" in str)
			printf("\033[1;32mOK \033[0m");
		else if (str != null && "KO" in str)
			printf("\033[1;31mKO [ %s] \033[0m", tab);
		else
			printf("\033[1;31m ERROR [ %s] \033[0m", tab);
	}
}

string tab_to_string(string[] tab)
{
	var str = "";
	foreach (var i in tab)
		str += @"\"$i\" ";
	return (str);
}

int main(string []args)
{
	var FD_PUSH = FileStream.open("push_swap", "r");

	if (FD_PUSH == null)
	{
		printf("\033[96;1m [INFO] \033[0m push_swap not found \n");
		FD_PUSH = FileStream.open("../push_swap", "r");
		printf("\033[96;1m [INFO] \033[0m recherche de push_swap  ../push_swap\n");
		if (FD_PUSH == null)
		{
			printf("\033[96;1m [INFO] \033[0m ../push_swap not found \n");
			return(-1);
		}
		else
		{
			push_swap_emp = "../push_swap";
			Posix.chmod("../push_swap", S_IRWXU);
		}
	}

	if (push_swap_emp == null)
	{
		push_swap_emp = "./push_swap";
		Posix.chmod("push_swap", S_IRWXU);
	}
	var FD_CHECKER = FileStream.open("./checker_linux", "r");

	if (FD_CHECKER == null)
	{
		Posix.system("wget -c https://projects.intra.42.fr/uploads/document/document/9218/checker_linux -q --show-progress");
		Posix.chmod("checker_linux", S_IRWXU);
		printf("\n");
	}
	if (args[1] == "help" || args[1] == "-h"){
		printf("\n[HELP]\n");
		printf("tester_push_swap [true|false|leak|valgrind| puissance(int)] [iteration(int)] \n");
		return (0);
	}

	if (args[1] == "leak" || args[1] == "valgrind"){
		g_only = MEMORY_LEAK;
		list_test();
		return (0);
	}
	if (args[1] == "true"){
		g_only = TRUE;
		list_test();
		return (0);
	}
	if (args[1] == "false"){
		g_only = FALSE;
		list_test();
		return (0);
	}
	else
		g_only = ALL;
	if (args.length == 1)
		list_test();
	else
		calc_moy(args);
	return (0);
}
