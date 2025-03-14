#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

bool tester_solution(int k, int *pos) {
  for (int i = 0; i < k; i++) {
    int j = pos[i];

    // Vérifier la colonne
    for (int l = 0; l < k; l++)
      if (pos[l] == j && i != l)
        return false;
        
    // Descendre diag
    for (int e = 1; i + e < k && j + e < k; e++)
      if (pos[i + e] == j + e)
        return false;

    // Remonter diag
    for (int e = 1; i - e > 0 && j - e > 0; e++)
      if (pos[i - e] == j - e)
        return false;
    
    // Descendre diag inversée (au sens des lignes)
    for (int e = 1; e + i < k && j - e > 0; e++) 
      if (pos[i + e] == j - e)
        return false;
    
    
    // Remonter diag inversée 
    for (int e = 1; i - e > 0 && j + e < k; e++)
      if (pos[i - e] == j + e)
        return false;
  }
  return true;
}

void afficher_tab(int k, int *tab) {
  for (int i = 0; i < k; i++)
    printf("%d, ", tab[i]);
  printf("\n");
}

void echanger(int *tab, int i, int j) {
  int t = tab[i];
  tab[i] = tab[j];
  tab[j] = t;
}

// En utilisant l'algorithme suivant https://fr.wikipedia.org/wiki/Algorithme_de_Heap
int *force_brute(int k) {
  int *a = malloc(sizeof(int) * k);
  int compteur[k];
  for (int i = 0; i < k; i++) {
    a[i] = i;
    compteur[i] = 0;
  }

  int i = 0;
  while (i < k) {
    if (compteur[i] < i) {
      if (!(i & 1)) 
        echanger(a, 0, i);
      else
        echanger(a, compteur[i], i);

      // Traiter la position
      if (tester_solution(k, a))
        return a;
      // afficher_tab(k, a);

      compteur[i]++;
      i = 0;
    } else {
      compteur[i] = 0;
      i++;
    }
  }
  printf("No solution found!\n");
  exit(EXIT_FAILURE);    
}

void afficher_plateau(int k, int *pos) {
  for (int i = 0; i < k; i++) {
    int j = pos[i];
    for (int l = 0; l < k; l++) {
      printf("%d", j == l);
    }
    printf("\n");
  }
}

int main() {
  int k = 13;
  int *soluce = force_brute(k);
  afficher_plateau(k, soluce);
  return EXIT_SUCCESS;
}
