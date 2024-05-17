# MPI_PingPong
Trabalho de MPI que recebe e envia informações.
Use o terminal Ubunto ele não funcina no Windows
códigos:
nano main.cpp
//Verifique se está o codigo
mpiCC -o TP  mpi_Maykoll_Rocha.cpp
//Para criar o executavel que vai ser no TP
mpirun -np 2 ./TP
//Para roda o codigo mesmo que aumento o valor 2 ainda será duas maquinas por tratamento
//Caso entre com algo muito maior que suma maquina ela morre
