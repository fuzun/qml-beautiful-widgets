#ifndef INTERFACE_H
#define INTERFACE_H

#include <QObject>

class Interface : public QObject
{
    Q_OBJECT
public:
    explicit Interface(QObject *parent = nullptr);

public:
    Q_INVOKABLE QStringList getDirFileList(const QString& dir) const;

private:


signals:

};

#endif // INTERFACE_H
