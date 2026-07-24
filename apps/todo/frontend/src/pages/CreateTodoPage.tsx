import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';

import type { CreateTodoInput } from '@todo/shared';

import { TodoForm } from '../components/TodoForm';
import { todoApi } from '../api/client';

export const CreateTodoPage = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: todoApi.create,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['todos'] });
      navigate('/');
    },
  });

  const handleSubmit = async (input: CreateTodoInput) => {
    await mutation.mutateAsync(input);
  };

  return (
    <section>
      <h1>Create todo</h1>
      {mutation.isError ? <p className="error">{(mutation.error as Error).message}</p> : null}
      <TodoForm isSubmitting={mutation.isPending} onSubmit={handleSubmit} />
    </section>
  );
};
