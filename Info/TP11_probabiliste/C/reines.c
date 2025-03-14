#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

bool tester_solution(int k, int *pos) {
  for (int i = 0; i < k; i++) {
    int j = pos[i];
    if (j == -1)
      continue;

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
    printf("%2d, ", tab[i]);
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


int *retour_sur_trace(int k) {
  int k_zaine_indice = 0;
  int *a = malloc(sizeof(int) * k);
  a[0] = 0;
  for (int i = 1; i < k; i++)
    a[i] = -1;

  while (a[0] < k) { // Si a[0] atteint k, on a testé toutes les positions possibles (mauvaise nouvelle)
    // afficher_tab(k, a);
    if (tester_solution(k, a)) {
      if (a[k - 1] != -1)
        return a;
      a[++k_zaine_indice] = 0;
    } else {
      while (a[k_zaine_indice] == k - 1) {
        a[k_zaine_indice--] = -1;
      }
      a[k_zaine_indice]++;
    }

  }
  printf("No solution found!\n");
  exit(EXIT_FAILURE);
}


void afficher_plateau(int k, int *pos) {
  for (int i = 0; i < k; i++) {
    int j = pos[i];
    for (int l = 0; l < k; l++) {
      printf("%s ", j == l ? "■" : "□");
    }
    printf("\n");
  }
}

int *las_vegas(int k) {
  exit(EXIT_FAILURE);
}

int main() {
  int k = 20;
  int *soluce = retour_sur_trace(k);
  afficher_plateau(k, soluce);
  return EXIT_SUCCESS;
}
