#include <vslc.h>

void node_print(node_t *root, int nesting)
{
    if (root != NULL) {
        printf("%*c%s", nesting, ' ', node_string[root->type]);

        if (root->type == IDENTIFIER_DATA || root->type == STRING_DATA ||
            root->type == EXPRESSION) {
            printf("(%s)", (char *) root->data);
        } else if (root->type == NUMBER_DATA) {
            printf("(%ld)", *((int64_t *) root->data));
        }

        putchar('\n');
        for (int64_t i = 0; i < root->n_children; i++) {
            node_print(root->children[i], nesting + 1);
        }
    } else {
        printf("%*c%p\n", nesting, ' ', root);
    }
}

node_t * node_init(node_t *nd, node_index_t type, void *data,
    uint64_t n_children, ...)
{
    *nd = (node_t) {
        type, data, NULL, n_children, malloc(n_children * sizeof(node_t *))
    };

    va_list ap;
    va_start(ap, n_children);

    for (int64_t i = 0; i < n_children; i++) {
        nd->children[i] = va_arg(ap, node_t *);
    }

    va_end(ap);

    return nd;
}

void node_finalize(node_t *discard)
{
    if (discard != NULL) {
        free(discard->data);
        free(discard->children);
        free(discard);
    }
}


void destroy_subtree(node_t *discard)
{
    if (discard != NULL) {
        for (uint64_t i = 0; i < discard->n_children; i++) {
            destroy_subtree(discard->children[i]);
        }
        node_finalize(discard);
    }
}
