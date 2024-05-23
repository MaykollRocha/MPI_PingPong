{"titulo": "Envio e Recebimento de Mensagem",
    "info": {
        "materia": "Sistemas Distribuidos",
        "data": "Janeiro de 2024",
        "local": "UFGD - Universidade Federal da Grande Dourados",
        "professor": "Rodrigo Porfírio da Silva Sacchi",
        "nota": "9.5",
    },
    "descricao": """
    O projeto consiste em utilizar duas máquinas virtuais para trocar um grande volume de informações, já que não temos uma conexão estável. Dentro de cada máquina, executamos dois processos distintos. Eles irão trocar um alto volume de informações, sendo que a quantidade de dados varia de 2^0 a 2^19, ou seja, de 1 a 524.288 valores. A troca de informações é realizada de forma não bloqueante tanto na hora de enviar quanto de receber. Inicialmente, os dados são enviados do processo 0 para o processo 1, e então o processo 1 retorna os dados para o vetor vazio do processo 0. O tempo necessário para essa operação é registrado.  
    O codigo foi feito para o terminal ubunto.
    """,
    "imag": [
        {
            "nome": "output.png",
            "rodape": "Saida do codigo no terminal Ubunto",
        },
    ],
    "codigos": [
        {
            "motivo": "Bibliotecas/Prototipações",
            "codigo": r"""
        #include <stdio.h>
        #include <mpi.h>
        #include <ctime>
        #include <cmath>
        #include <random>    
        
        void print_com_verificacao(double dadosE[], double dadosR[],double Fim,double Inicio,int tam);
        void print_sem_verificacao(double dadosE[], double dadosR[],double Fim,double Inicio,int tam);
        void encherce_envio(double dadosE[],int tam);   
         """,
            "descricao": "Funções protótipos",
        },
        {
            "motivo": "Main",
            "codigo": r"""
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
            """,
                "descricao": "Função Principal que faz o ping-pong",
            },
            {
                "motivo": "Encher Matriz",
                "codigo": r"""
            void encherce_envio(double dadosE[],int tam){
                std::uniform_real_distribution<double>unif(0,10000);
                std::default_random_engine re;
                for( int i = 0; i < tam; i ++)dadosE[i] = unif(re);
            }   
            """,
                "descricao": "Encher os Vatores com numeros rodômicos Aleatórios",
            },
        ],
        "agregamento": """Foi realmente um trabalho muito tranquilo, não demorei mais de uma semana, gostei de cada segundo programando este, alem
        de que meu colega de sala fazia outra matéria com o mesmo onde tinha a mesma ideia de projeto só que era com o send e recive bloquenate.""",
        "Link": "https://github.com/MaykollRocha/MPI_PingPong/tree/main",
    },
    
