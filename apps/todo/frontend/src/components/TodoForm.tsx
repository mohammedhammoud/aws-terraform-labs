import { useState, type FormEvent } from 'react';

import { createTodoSchema, updateTodoSchema } from '@todo/shared';

import type { CreateTodoInput, Todo, UpdateTodoInput } from '@todo/shared';

type BaseTodoFormProps = {
  isSubmitting: boolean;
};

type CreateTodoFormProps = BaseTodoFormProps & {
  initialValue?: undefined;
  onSubmit: (value: CreateTodoInput) => Promise<void>;
};

type EditTodoFormProps = BaseTodoFormProps & {
  initialValue: Todo;
  onSubmit: (value: UpdateTodoInput) => Promise<void>;
};

type TodoFormProps = CreateTodoFormProps | EditTodoFormProps;

export const TodoForm = ({ initialValue, isSubmitting, onSubmit }: TodoFormProps) => {
  const [title, setTitle] = useState(initialValue?.title ?? '');
  const [completed, setCompleted] = useState(initialValue?.completed ?? false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (initialValue) {
      const result = updateTodoSchema.safeParse({ title, completed });

      if (!result.success) {
        setError(result.error.issues[0]?.message ?? 'Invalid input');
        return;
      }

      setError(null);
      await onSubmit(result.data);
      return;
    }

    const result = createTodoSchema.safeParse({ title });

    if (!result.success) {
      setError(result.error.issues[0]?.message ?? 'Invalid input');
      return;
    }

    setError(null);
    await onSubmit(result.data);
  };

  return (
    <form className="card form" onSubmit={handleSubmit}>
      <label>
        <span>Title</span>
        <input value={title} onChange={(event) => setTitle(event.target.value)} placeholder="Buy milk" />
      </label>

      {initialValue ? (
        <label className="checkbox-row">
          <input
            checked={completed}
            onChange={(event) => setCompleted(event.target.checked)}
            type="checkbox"
          />
          <span>Completed</span>
        </label>
      ) : null}

      {error ? <p className="error">{error}</p> : null}

      <button disabled={isSubmitting} type="submit">
        {isSubmitting ? 'Saving...' : 'Save todo'}
      </button>
    </form>
  );
};
