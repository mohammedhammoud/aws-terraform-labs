import { Link } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';

import { todoApi } from '../api/client';

const todosQueryKey = ['todos'];

export const TodoListPage = () => {
  const queryClient = useQueryClient();
  const todosQuery = useQuery({ queryKey: todosQueryKey, queryFn: todoApi.list });

  const deleteMutation = useMutation({
    mutationFn: todoApi.remove,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: todosQueryKey });
    },
  });

  const toggleMutation = useMutation({
    mutationFn: ({ id, title, completed }: { id: number; title: string; completed: boolean }) =>
      todoApi.update(id, { title, completed }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: todosQueryKey });
    },
  });

  if (todosQuery.isLoading) {
    return <p>Loading...</p>;
  }

  if (todosQuery.isError) {
    return <p className="error">{(todosQuery.error as Error).message}</p>;
  }

  const todos = todosQuery.data ?? [];

  return (
    <section>
      <div className="page-header">
        <h1>Todos</h1>
        <Link className="button-link" to="/todos/new">
          Create todo
        </Link>
      </div>

      {todos.length === 0 ? <p className="card">No todos yet.</p> : null}

      <ul className="todo-list">
        {todos.map((todo) => (
          <li className="card todo-item" key={todo.id}>
            <label className="checkbox-row grow">
              <input
                checked={todo.completed}
                onChange={() =>
                  toggleMutation.mutate({
                    id: todo.id,
                    title: todo.title,
                    completed: !todo.completed,
                  })
                }
                type="checkbox"
              />
              <span className={todo.completed ? 'completed' : ''}>{todo.title}</span>
            </label>

            <div className="actions">
              <Link className="button-link secondary" to={`/todos/${todo.id}/edit`}>
                Edit
              </Link>
              <button onClick={() => deleteMutation.mutate(todo.id)} type="button">
                Delete
              </button>
            </div>
          </li>
        ))}
      </ul>
    </section>
  );
};
