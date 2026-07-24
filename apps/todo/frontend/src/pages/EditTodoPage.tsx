import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Link, useNavigate, useParams } from 'react-router-dom';

import type { UpdateTodoInput } from '@todo/shared';

import { TodoForm } from '../components/TodoForm';
import { todoApi } from '../api/client';

export const EditTodoPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const todoId = Number(id);

  const todoQuery = useQuery({
    queryKey: ['todo', todoId],
    queryFn: () => todoApi.getById(todoId),
    enabled: Number.isInteger(todoId) && todoId > 0,
  });

  const mutation = useMutation({
    mutationFn: (input: UpdateTodoInput) => todoApi.update(todoId, input),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['todos'] });
      await queryClient.invalidateQueries({ queryKey: ['todo', todoId] });
      navigate('/');
    },
  });

  if (!Number.isInteger(todoId) || todoId <= 0) {
    return <p className="error">Invalid todo id.</p>;
  }

  if (todoQuery.isLoading) {
    return <p>Loading...</p>;
  }

  if (todoQuery.isError) {
    return (
      <section>
        <p className="error">{(todoQuery.error as Error).message}</p>
        <Link className="button-link secondary" to="/">
          Back
        </Link>
      </section>
    );
  }

  const todo = todoQuery.data;

  if (!todo) {
    return <p className="error">Todo not found.</p>;
  }

  const handleSubmit = async (input: UpdateTodoInput) => {
    await mutation.mutateAsync(input);
  };

  return (
    <section>
      <h1>Edit todo</h1>
      {mutation.isError ? <p className="error">{(mutation.error as Error).message}</p> : null}
      <TodoForm initialValue={todo} isSubmitting={mutation.isPending} onSubmit={handleSubmit} />
    </section>
  );
};
