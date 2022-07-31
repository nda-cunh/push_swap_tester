using Posix;

void list_test()
{
	/* TRUE = GOOD  */
	/* FALSE = ERROR */

	test({"5", "4", "3"}, true);
	test({"5", "1", "0", "2"}, true);
	test({"5 4A 3"}, false);
	test({"5 2 3 4 8"}, true);
	test({"42 -500 -2845 -21 54784 1541"}, true);
	test({"42", "500", "-2845", "-21", " 54784", "1541"}, true);
	test({"52 14 15"}, true);
	test({"52"}, true);
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

}

void test(string[] arg, bool compare)
{
	var tab = tab_to_string(arg);
	system(@"./push_swap $(tab) 1>tmp_1  2> tmp_2");
	var FD_ERR = FileStream.open("tmp_2", "r");
	var str = FD_ERR.read_line();
   

	if (compare == false)
	{
		if (str == "Error")
			print("\033[1;32mOK \033[0m");
		else
			print("\033[1;31mKO [ %s] \033[0m", tab);
	}
	else
	{
		system(@"cat tmp_1 | ./checker_linux $(tab) > tmp_3");
		var FD_OUT = FileStream.open("tmp_3", "r");
		str = FD_OUT.read_line();
		if ("OK" in str)
			print("\033[1;32mOK \033[0m");
		else if ("KO" in str)
			print("\033[1;31mKO [ %s] \033[0m", tab);
		else
			print("ERR");
	}
	system("rm -rf tmp_1 tmp_2 tmp_3");
}

string tab_to_string(string[] tab)
{
	var str = "";
	foreach (var i in tab)
		str += @"\"$(i)\" ";
	return (str);
}

int main(string []args)
{
	var FD_PUSH = FileStream.open("push_swap", "r");
	
	if (FD_PUSH == null)
	{
		print("\033[96;1m [INFO] \033[0m push_swap not found \n");
		return (-1);
	}
	chmod("push_swap", S_IRWXU);
	var FD_CHECKER = FileStream.open("./checker_linux", "r");
	
	if (FD_CHECKER == null)
    {
        system("wget -c https://projects.intra.42.fr/uploads/document/document/9218/checker_linux");
		chmod("checker_linux", S_IRWXU);
    }
	if (args.length == 1)
		list_test();
	else
		calc_moy(args);
	return (0);
}
