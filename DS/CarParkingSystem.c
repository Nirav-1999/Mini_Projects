// # basic_ds_project
// Virtual Car Parking System

// A simple car parking system using linked lists and stack where cars are parked according to the availability of the parking lot.

#include<stdio.h>
#include<conio.h>
#include<string.h>
#include<stdlib.h>
int stack[2], man = -1, rate = 50;

struct node
{
	char license[20];
	char name[20];
	int token;
	int cost;
	int waiting;
	struct node *next;
};
struct node *front = NULL;
struct node *rear = NULL;
int top = -1;
int count = 0;
int flag = 0;
char temp[2][20];
int ttemp[2];
void insertRear();
void insertFront();
void deleteFront();
void display();
int main(void)
{
    printf("Welcome to our Parking Lot!\nEnter '-1' to exit\n");
    printf("--------------------------\n");
    printf("--------------------------\n");
    printf("1. ARRIVAL\n2. DEPARTURE\n3. STATUS\n");

	int option;
	Now : while(1)
	{

        printf("--------------------------\n");
        printf("OPTION: ");
		scanf("%d", &option);
		switch(option)
		{
			case 1: insertRear();
					break;
			case 2: deleteFront();
					break;
			case 3: display();
					break;
			case -1:printf("\nThank you for using our service!");
                    return 0;
			default:printf("\n****Error : Invalid Option ****\n");
					goto Now;
		}
	}
}
void insertRear()
{
	    char lpn[20];
        int hours;
		struct node *nn;
		nn = (struct node *)malloc(sizeof(struct node));
		printf("Enter owner's name:");
		scanf("%s", &(nn->name));
		printf("Enter number of hours:");
		scanf("%d", &hours);
		nn->cost=hours*rate;
		printf("Enter license Plate Number:");
		getchar();
		fgets(lpn, 20, stdin);
		strcpy(nn->license, lpn);
		//scanf("%s",&(nn->license));
		if(man == -1)
            nn->token= ++flag;
        else
            nn->token = stack[man--];
		nn->next=NULL;
		printf("Your Token number is %d\n", (nn->token));
		printf("Total cost is %d/- Rupees\n", (nn->cost));
		if(front == NULL)
		{
			front = nn;
			rear = nn;
		}
		else
		{
			rear->next = nn;
			rear = nn;
		}
		count++;
    if(count<2)
    {
        printf("Car successfully parked\n");
        nn->waiting = 0;
	}
	else
	{
		printf("You have been added to the waiting list\n");
		nn->waiting = 1;
	}
}
void deleteFront()
{
	if(front == NULL)
	{
		printf("Error : No Car In Parking\n");
		return;
	}
	else
	{
		int i;
		struct node *p,*q, *r;
		printf("Enter The Token  : ");
		scanf("%d",&i);
		p = front;
		if(p->token == i)
		{
		    stack[++man] = p->token;
			front = p->next;
                r = p;
				while(r->waiting!=1&&r->next!=NULL){
                r = r->next;
                r->waiting = 0;

			}
			free(p);
			count--;

			return;
		}
		else
		{
			while(p != NULL)
			{
				if(p->token == i)
					break;
				else
					p = p->next;
			}
			if(p == NULL)
			{
				printf("Error : No Such Car\n");
				return;
			}
			p=front;
			while(p != NULL)
			{
				if(p->token == i)
					break;
				else
				{
					strcpy(temp[++top], p->license);
					ttemp[top] = p->token;
					q = p->next;
					free(p);
					p = q;
				}
			}
			if(p->next != NULL)
			{
				front = p->next;
				free(p);
				count--;
			}
			else if(p->next==NULL)
			{
				front = NULL;
				free(p);
				count--;
				rear = NULL;
			}
		}
		insertFront();
	}
}
void insertFront()
{
	while(top != -1)
	{
		struct node *p,*nn;
		nn= (struct node *)malloc(sizeof(struct node));
		if(rear == NULL)
            rear = nn;
		nn->token = ttemp[top];
		strcpy(nn->license , temp[top--]);
		nn->next= front;
		front = nn;
	}
}
void display()
{
	struct node *p;
	p = front;
	while(p != NULL)
	{   if(p->waiting == 0)
            printf("Token Number: %d\t Owner's Name: %s \t Cost: %d/- Rupees\t License Plate Number: %s\n", p->token, p->name, p->cost, p->license);
		else
            printf("Token Number: %d\t Owner's Name: %s \t Cost: %d/- Rupees\t License Plate Number: %s \t WAITING\n ", p->token, p->name, p->cost, p->license);
		p = p->next;
	}
}

