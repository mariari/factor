/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004 Slava Pestov.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package factor.jedit;

import factor.*;
import java.util.*;
import javax.swing.ListCellRenderer;
import org.gjt.sp.jedit.textarea.*;
import org.gjt.sp.jedit.*;
import sidekick.*;

public class FactorCompletion extends SideKickCompletion
{
	private View view;
	private JEditTextArea textArea;
	private String word;
	private FactorParsedData data;

	//{{{ FactorCompletion constructor
	public FactorCompletion(View view, FactorWord[] items,
		String word, FactorParsedData data)
	{
		this.view = view;
		textArea = view.getTextArea();
		this.items = Arrays.asList(items);
		this.word = word;
		this.data = data;
	} //}}}

	public String getLongestPrefix()
	{
		return MiscUtilities.getLongestPrefix(items,false);
	}

	public void insert(int index)
	{
		FactorWord selected = ((FactorWord)get(index));
		String insert = selected.name.substring(word.length());

		Buffer buffer = textArea.getBuffer();

		try
		{
			buffer.beginCompoundEdit();
			
			textArea.setSelectedText(insert);
			if(!FactorPlugin.isUsed(view,selected.vocabulary))
				FactorPlugin.insertUse(view,selected.vocabulary);
		}
		finally
		{
			buffer.endCompoundEdit();
		}
	}

	public int getTokenLength()
	{
		return word.length();
	}

	public boolean handleKeystroke(int selectedIndex, char keyChar)
	{
		if(keyChar == '\t' || keyChar == '\n')
			insert(selectedIndex);
		else
			textArea.userInput(keyChar);

		boolean ws = (ReadTable.DEFAULT_READTABLE
			.getCharacterType(keyChar)
			== ReadTable.WHITESPACE);

		return !ws;
	}

	public ListCellRenderer getRenderer()
	{
		return new FactorWordRenderer(data.parser,false);
	}
}
