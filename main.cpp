/***
*
* UFGD - UNIVERSIDADE FEDERAL DA GRANDE DOURADOS
* 	      Sistemas Distribuídos
* 		Trabalho Prático
* 	      Aluno: Maykoll Rocha
*
***/



#include <stdio.h>
#include <mpi.h>
#include <ctime>
#include <cmath>
#include <random>



void print_com_verificacao(double dadosE[], double dadosR[],double Fim,double Inicio,int tam);

void print_sem_verificacao(double dadosE[], double dadosR[],double Fim,double Inicio,int tam);

void encherce_envio(double dadosE[],int tam);

int main()
{
	int rank;//Não vou utilizar o size então não vou pedir a entrada deste so dos rankings
	MPI_Init(NULL, NULL);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);

	//Caso entre com um rank maior que 1 que seria mais de 2 maquinas ele simplesmente)
	if(rank > 1){
		 MPI_Finalize();
		 return 0 ;
	}
	//Apenas o printa o cabeça-lho da tabela.
	if(rank == 0){
		 printf("+-------+-----------------+---------------+\n");
		 printf("|n      | tempo(segundos) |  Taxa(MB/s)   |\n");
		 printf("|-------+-----------------+---------------|\n");
	}
	for (int i = 0; i < 20; i++)
	{
		int tam = pow(2, i);
		double *dadosE = new double[tam]; // Aloca o vetor de envio dinamicamente 
		double *dadosR = new double[tam]; // Aloca o vetor de recebimento dinamicamente
		//OBS: O rank 1 não usa o vetor de DadosE so de so o dadosR e elvia o mesmo que chega em tal
		//para o ranking 0;

		//Enche o vetor de recebimento com os números aleatórios dos dois rank que
		//Cria um distribuição de numero reais aletorios entre 0 e 10000
		//Para que os dados enviado pelo Maquina 1 seja diferente da 2 os dois possiem uma semente diferente
		//Sendo a semente 1000 e a semente 1001
		if(rank == 0)encherce_envio(dadosE,tam);

		MPI_Request send_request, recv_request;
		//Calcula o tempo inicial
		double Inicio = MPI_Wtime();

		for (int j = 0; j < tam; j++)
		{
		    if (rank == 0)
		    {
		        MPI_Isend(&dadosE[j], 1, MPI_DOUBLE, 1, 0, MPI_COMM_WORLD, &send_request);
			MPI_Wait(&send_request, MPI_STATUS_IGNORE);
		        MPI_Irecv(&dadosR[j], 1, MPI_DOUBLE, 1, 0, MPI_COMM_WORLD, &recv_request);
		      	MPI_Wait(&recv_request, MPI_STATUS_IGNORE);
			}
		    else if (rank == 1)
		    {
		        MPI_Irecv(&dadosR[j], 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, &recv_request);
			MPI_Wait(&recv_request, MPI_STATUS_IGNORE);
		        MPI_Isend(&dadosR[j], 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, &send_request);
		        MPI_Wait(&send_request, MPI_STATUS_IGNORE);
			}
		}
		//Pega o tempo final
		 double Fim = MPI_Wtime();

		//O primeiro print checa se o mesmoq ue chegou no rank 1 é o mesmo que saio do 
		//Envio do 0 e chegou nele novemente pelo 1
		//if (rank == 0)print_com_verificacao(dadosE,dadosR,Fim,Inicio,tam);
		if (rank == 0)print_sem_verificacao(dadosE,dadosR,Fim,Inicio,tam);

		 delete[] dadosE;
		 delete[] dadosR;
	}
	if(rank==0)printf("+-------+-----------------+---------------+\n");
	MPI_Finalize();

	return 0;
}

void print_com_verificacao(double dadosE[], double dadosR[],double Fim,double Inicio,int tam){
	bool dado_corret = true;
	for(int j = 0; j < tam;j++){
	  	if(dadosE[j] != dadosR[j]){
			dado_corret = false;
			break;
		}
	}
	double tempo = Fim - Inicio;//Por já estar em segundo não é nescessario fazer consão de clock como a time.h
	double taxa = tam/tempo/1024/1024;// Consão da Taxa ela é dada em byts/s e divide 2 veza por 1024 para ir pra MB/s
	printf("|%-6d |   %-.9f   |  %-.9f  |  %s\n",tam,tempo,taxa,dado_corret?"Correto":"Incorreto");
}

void print_sem_verificacao(double dadosE[], double dadosR[],double Fim,double Inicio,int tam){
	double tempo = Fim - Inicio;//Por já estar em segundo não é nescessario fazer consão de clock como a time.h
	double taxa = tam/tempo/1024/1024;// Consão da Taxa ela é dada em byts/s e divide 2 veza por 1024 para ir pra MB/s
        printf("|%-6d |   %-.9f   |  %-.9f  |\n",tam,tempo,taxa);
}

void encherce_envio(double dadosE[],int tam){
	std::uniform_real_distribution<double>unif(0,10000);
	std::default_random_engine re;
	for( int i = 0; i < tam; i ++)dadosE[i] = unif(re);
}
