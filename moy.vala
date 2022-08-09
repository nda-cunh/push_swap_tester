using Posix;

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

int ft_count_line()
{
    var fd = FileStream.open ("my_file", "r");
    var i = 0;

    while (fd.read_line() != null)
        i++;
    return (i);
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
        var str = ft_tab_to_string(tab);
        system(@"$(push_swap_emp) \"$(str)\" > my_file");
        system(@"cat ./my_file | ./checker_linux $(str)");
        nbr = ft_count_line();
        if(nbr > max)
            max = nbr;
        moy += nbr;
        if (puissance <= 100)
		{
			if (nbr < 700)
				print(@"Nombre de coups : \033[1m$(nbr)\033[0m\n");
			else if (nbr < 900)
				print(@"Nombre de coups : \033[1;34m$(nbr)\033[0m\n");
			else if (nbr < 1100)
				print(@"Nombre de coups : \033[1;32m$(nbr)\033[0m\n");
			else if (nbr < 1500)
				print(@"Nombre de coups : \033[1;33$(nbr)\033[0m\n");
			else
				print(@"Nombre de coups : \033[1;31m$(nbr)\033[0m\n");
		}
		else if (puissance <= 500)
		{
			if (nbr < 5500)
				print(@"Nombre de coups : \033[1m$(nbr)\033[0m\n");
			else if (nbr < 7000)
				print(@"Nombre de coups : \033[1;34m$(nbr)\033[0m\n");
			else if (nbr < 8500)
				print(@"Nombre de coups : \033[1;32m$(nbr)\033[0m\n");
			else if (nbr < 11500)
				print(@"Nombre de coups : \033[1;33$(nbr)\033[0m\n");
			else
				print(@"Nombre de coups : \033[1;31m$(nbr)\033[0m\n");
		}
        i++;
    }
    print(@"MAX :		\033[1;31;6m$(max)\n\033[0m");
	moy /= i;
	if (puissance <= 100)
	{
		if (moy < 700)
    		print(@"moyenne:	\033[1m$(moy)\033[0m\n");
		else if (moy < 900)
    		print(@"moyenne:	\033[1;34m$(moy)\033[0m\n");
		else if (moy < 1100)
    		print(@"moyenne:	\033[1;32m$(moy)\033[0m\n");
		else if (moy < 1500)
    		print(@"moyenne:	\033[1;33m$(moy)\033[0m\n");
		else
    		print(@"moyenne:	\033[1;31m$(moy)\033[0m\n");
	}
	else if (puissance <= 500)
	{
		if (moy < 5500)
    		print(@"moyenne:	\033[1m$(moy)\033[0m\n");
		else if (moy < 7000)
    		print(@"moyenne:	\033[1;34m$(moy)\033[0m\n");
		else if (moy < 8500)
    		print(@"moyenne:	\033[1;32m$(moy)\033[0m\n");
		else if (moy < 11500)
    		print(@"moyenne:	\033[1;33m$(moy)\033[0m\n");
		else
    		print(@"moyenne:	\033[1;31m$(moy)\033[0m\n");
	}
	system("rm my_file");
}
