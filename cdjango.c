#include "Python.h"

#include "gramparse.h"

void yyerror(YYLTYPE *llocp, yyscan_t yyscanner, char *message);

static PyObject *compile_template(PyObject *self, PyObject *args);

static PyMethodDef CDjangoMethods[] = {
    {"compile_template",  compile_template, METH_VARARGS,
     "Complile a CDjango template."},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

static struct PyModuleDef cdjangomodule = {
	PyModuleDef_HEAD_INIT,
	"cdjango",
	NULL,
	0,
	CDjangoMethods
};

PyMODINIT_FUNC
PyInit_cdjango(void)
{
	return PyModule_Create(&cdjangomodule);
}


void yyerror(YYLTYPE *llocp, yyscan_t yyscanner, char *message)
{
}

static PyObject *
compile_template(PyObject *self, PyObject *args)
{
	char const *filename;
	yyscan_t scanner;
	FILE *file;
	yy_extra_type yyextra;
	int res;

	if (!PyArg_ParseTuple(args, "s", &filename)) {
		return NULL;
	}

	file = fopen(filename, "r");
	if (file == NULL) {
		/* error */
		return NULL;
	}

	scanner = scanner_init(file, &yyextra);
	parser_init();
	yyparse(scanner);
	res = scanner_finish(scanner);
	fclose(file);

	return PyLong_FromLong(res);
}
