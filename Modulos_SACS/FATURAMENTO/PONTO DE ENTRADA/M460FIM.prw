#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460FIM     �Autor  �Guilherme Giuliano� Data �  14/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada no faturamento do pedido para levar inf  ���
���          � orma�oes para a Nota                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Sacs                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*****************************************************************************
User Function M460FIM
*****************************************************************************

IF !EMPTY(SC5->C5_CRIADOR)
	RecLock("SF2",.F.)
	SF2->F2_CRIADOR := SC5->C5_CRIADOR
	MsUnlock()
ENDIF

Return