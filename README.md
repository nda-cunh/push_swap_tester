# Installation:

```valac main.vala moy.vala --pkg=posix -o push_swap_tester```

pour ajouter les optimisations de GCC (optionnelle):
``( -X -O3 )``

# Utilisation:

sans argument il testera les erreures des entrées
```./push_swap_tester``` 

<img src="withoutarg.png">

Sinon il prend 1 ou 2 parametres dont la puissance et le nombres de fois (10 par défauts)
il calculera donc la moyenne et la valeur max obtenue.

<img src="arg2.png">


Note:
il doit y avoir `checker_linux` à coté de lui ainsi que l'executable `push_swap`.
si checker_linux n'est pas trouvé celui-ci sera téléchargé de lui même.
